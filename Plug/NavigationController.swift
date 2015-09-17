//
//  NavigationController.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa
import SnapKit

class NavigationController: NSViewController {
    var navigationBarController: NavigationBarController!
    var contentView: NSView!

    var viewControllers: [BaseContentViewController] {
        return childViewControllers as! [BaseContentViewController]
    }
    var topViewController: BaseContentViewController! {
        return viewControllers.last
    }
    var nextTopViewController: BaseContentViewController? {
        if viewControllers.count > 1 {
            return viewControllers[viewControllers.count - 2]
        } else {
            return nil
        }

    }
    var rootViewController: BaseContentViewController! {
        return viewControllers.first
    }
    var visibleViewController: BaseContentViewController! {
        return topViewController
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        navigationBarController = NavigationBarController(navigationController: self)
        view.addSubview(navigationBarController.view)
        navigationBarController.view.snp_makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
        contentView = NSView(frame: NSZeroRect)
        view.addSubview(contentView)
        contentView.snp_makeConstraints { make in
            make.top.equalTo(navigationBarController.view.snp_bottom)
            make.left.equalTo(view)
            make.bottom.equalTo(view)
            make.right.equalTo(view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.wantsLayer = true
        Notifications.subscribe(observer: self, selector: "pushViewControllerNotification:", name: Notifications.PushViewController, object: nil)
    }
    
    func pushViewControllerNotification(notification: NSNotification) {
        let viewController = notification.userInfo!["viewController"] as! BaseContentViewController
        pushViewController(viewController)
    }
    
    func setNewRootViewController(viewController: BaseContentViewController) {
        if rootViewController === viewController {
            if rootViewController === topViewController {
                print("Can't transition to current view controller")
            } else {
                popToRootViewController()
            }
            return
        }
        
        if topViewController != nil {
            topViewController.view.removeFromSuperview()
            topViewController.didLoseCurrentViewController()
        }
        
        addChildViewController(viewController)
        contentView.addSubview(viewController.view)
        viewController.view.snp_makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        viewController.didBecomeCurrentViewController()
        
        removeAllViewControllersExcept(viewController)
        
        Analytics.trackView(visibleViewController.analyticsViewName)
        navigationBarController.setNavigationItems([viewController.navigationItem])
    }
    
    func pushViewController(viewController: BaseContentViewController) {
        addChildViewController(viewController)
        transitionFromViewController(nextTopViewController, toViewController: topViewController, reversed: false)
        
        Analytics.trackView(visibleViewController.analyticsViewName)
        navigationBarController.pushNavigationItem(viewController.navigationItem, animated: true)
    }
    
    func popViewController() -> BaseContentViewController? {
        if !canPopViewController() { return nil }
        
        transitionFromViewController(visibleViewController, toViewController: nextTopViewController!, reversed: true)
        let poppedController = removeTopViewController()
        
        Analytics.trackView(visibleViewController.analyticsViewName)
        navigationBarController.popNavigationItemAnimated(true)
        
        return poppedController
    }
    
    func popToRootViewController() -> [BaseContentViewController] {
        return popToViewController(rootViewController)
    }
    
    func popToViewController(viewController: BaseContentViewController) -> [BaseContentViewController] {
        if !canPopViewController() { return [] }
        if !canPopToViewController(viewController) { return [] }
        
        transitionFromViewController(visibleViewController, toViewController: viewController,  reversed: true)
        let poppedControllers = removeViewControllersAbove(viewController)
        
        Analytics.trackView(visibleViewController.analyticsViewName)
        navigationBarController.popToNavigationItem(viewController.navigationItem, animated: true)
        
        return poppedControllers
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        popViewController()
    }
    
    // MARK: Private methods
    
    private func removeViewControllersAbove(viewController: BaseContentViewController) -> [BaseContentViewController] {
        var removedControllers = [BaseContentViewController]()
        while topViewController !== viewController {
            let controller = topViewController
            controller.removeFromParentViewController()
            removedControllers.append(controller)
        }
        return removedControllers
    }
    
    private func removeAllViewControllersExcept(viewController: BaseContentViewController) -> [BaseContentViewController] {
        var removedControllers = [BaseContentViewController]()
        for controller in viewControllers {
            if controller !== viewController {
                controller.removeFromParentViewController()
                removedControllers.append(controller)
            }
        }
        return removedControllers
    }
    
    private func removeTopViewController() -> BaseContentViewController {
        let poppedController = topViewController
        poppedController.removeFromParentViewController()
        return poppedController
    }
    
    private func canPopViewController() -> Bool {
        return viewControllers.count > 1
    }
    
    private func canPopToViewController(viewController: BaseContentViewController) -> Bool {
        return hasChildViewController(viewController)
    }
    
    private func hasChildViewController(viewController: BaseContentViewController) -> Bool {
        return viewController.parentViewController === self
    }
    
    private func transitionFromViewController(fromViewController: BaseContentViewController!, toViewController: BaseContentViewController!, reversed: Bool) {

        contentView.addSubview(toViewController.view)
        toViewController.view.snp_makeConstraints { make in
            make.size.equalTo(contentView)
            make.top.equalTo(contentView)
            if reversed {
                make.right.equalTo(contentView.snp_left)
            } else {
                make.left.equalTo(contentView.snp_right)
            }
        }
        
        self.contentView.layoutSubtreeIfNeeded()
        
        fromViewController.view.snp_remakeConstraints { make in
            make.size.equalTo(contentView)
            make.top.equalTo(contentView)
            if reversed {
                make.left.equalTo(contentView.snp_right)
            } else {
                make.right.equalTo(contentView.snp_left)
            }
        }
        toViewController.view.snp_remakeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.25
                context.allowsImplicitAnimation = true
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                self.contentView.layoutSubtreeIfNeeded()
            }, completionHandler: {
                fromViewController.view.removeFromSuperview()
                if fromViewController != nil {
                    fromViewController.didLoseCurrentViewController()
                }
                toViewController.didBecomeCurrentViewController()
            }
        )
    }
    
    private func transitionOptions(reversed: Bool) -> NSViewControllerTransitionOptions {
        if reversed {
            return NSViewControllerTransitionOptions.SlideRight.union(NSViewControllerTransitionOptions.Crossfade)
        } else {
            return NSViewControllerTransitionOptions.SlideLeft.union(NSViewControllerTransitionOptions.Crossfade)
        }
    }
}
