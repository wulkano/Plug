//
//  NavigationController.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa
import SnapKit

// TODO: Analytics
// TODO: DidBecome...
// TODO: DidLose...

class NavigationController: NSViewController {
    static var sharedInstance: NavigationController?
    
    private var _viewControllers: [BaseContentViewController]
    var viewControllers: [BaseContentViewController] {
        get { return _viewControllers }
        set { setViewControllers(newValue, animated: false) }
    }
    var visibleViewController: BaseContentViewController
    var topViewController: BaseContentViewController {
        guard let topViewController = viewControllers.last else {
            fatalError("No top view controller")
        }
        return topViewController
    }
    var contentView: NSView!
    var navigationBarController: NavigationBarController!
    
    init!(rootViewController: BaseContentViewController?) {
        if let rootViewController = rootViewController {
            self._viewControllers = [rootViewController]
        } else {
            self._viewControllers = [BaseContentViewController(title: "Dummy controller", analyticsViewName: "Dummy controller")!]
        }
        self.visibleViewController = self._viewControllers.first!
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView(frame: NSZeroRect)
        
        self.navigationBarController = NavigationBarController(navigationController: self)
        self.view.addSubview(navigationBarController.view)
        self.navigationBarController.view.snp_makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        self.contentView = NSView(frame: NSZeroRect)
        self.view.addSubview(self.contentView)
        self.contentView.snp_makeConstraints { make in
            make.top.equalTo(self.navigationBarController.view.snp_bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    func pushViewController(viewController: BaseContentViewController, animated: Bool) {
        guard viewController.parentViewController == nil else {
            fatalError("Pushed view controller already has parent view controller")
        }
        
        self._viewControllers.append(viewController)
        self.addChildViewController(viewController)
        self.updateVisibleViewControllerAnimated(animated)
        
        self.navigationBarController.pushNavigationItem(viewController.navigationItem, animated: animated)
    }
    
    func popViewControllerAnimated(animated: Bool) -> BaseContentViewController? {
        guard self.viewControllers.count > 1 else {
            print("Can't pop last view controller")
            return nil
        }
        
        let poppedViewControllerIndex = self._viewControllers.count - 1
        let poppedViewController = self._viewControllers[poppedViewControllerIndex]
        self._viewControllers.removeAtIndex(poppedViewControllerIndex)
        poppedViewController.removeFromParentViewController()
        self.updateVisibleViewControllerAnimated(animated)
        
        self.navigationBarController.popNavigationItemAnimated(animated)
        
        return poppedViewController
    }
    
    func setViewControllers(newViewControllers: [BaseContentViewController], animated: Bool) {
        guard newViewControllers.count > 0 else {
            fatalError("Can't set viewControllers to empty array")
        }
        
        self._viewControllers.forEach { $0.removeFromParentViewController() }
        self._viewControllers = newViewControllers
        self._viewControllers.forEach { self.addChildViewController($0) }
        
        self.updateVisibleViewControllerAnimated(animated)
        
        self.navigationBarController.setNavigationItems(newViewControllers.map {$0.navigationItem})
    }
    
    // MARK: Private
    
    private func updateVisibleViewControllerAnimated(animated: Bool) {
        let newVisibleViewController = self.topViewController
        let oldVisibleViewController = self.visibleViewController
        
        guard newVisibleViewController != oldVisibleViewController else {
            print("No need to call updateVisibleViewControllerAnimated here")
            return
        }
        
        self.contentView.addSubview(newVisibleViewController.view)
        
        if animated {
            let isPushing = self._viewControllers.indexOf(oldVisibleViewController) != nil
            self.constrainViewControllerToSideOfContentView(newVisibleViewController, side: isPushing ? .Right : .Left)
            self.contentView.layoutSubtreeIfNeeded()
            self.constrainViewControllerToContentView(newVisibleViewController)
            self.constrainViewControllerToSideOfContentView(oldVisibleViewController, side: isPushing ? .Left : .Right)
            self.startAnimation(completionHandler: {
                oldVisibleViewController.view.removeFromSuperview()
            })
        } else {
            self.constrainViewControllerToContentView(newVisibleViewController)
            oldVisibleViewController.view.removeFromSuperview()
        }
        
        self.visibleViewController = newVisibleViewController
    }
    
    private func constrainViewControllerToContentView(viewController: BaseContentViewController) {
        let closure = { (make: ConstraintMaker)->Void in
            make.edges.equalTo(self.contentView)
        }
        self.makeOrRemakeConstraints(viewController, closure: closure)
    }
    
    private func constrainViewControllerToSideOfContentView(viewController: BaseContentViewController, side: ContentViewSide) {
        let closure = { (make: ConstraintMaker)->Void in
            make.top.bottom.width.equalTo(self.contentView)
            switch side {
            case .Left:
                make.right.equalTo(self.contentView.snp_left)
            case .Right:
                make.left.equalTo(self.contentView.snp_right)
            }
        }
        self.makeOrRemakeConstraints(viewController, closure: closure)
    }
    
    private func startAnimation(completionHandler completionHandler: ()->Void) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.contentView.layoutSubtreeIfNeeded()
        }, completionHandler: {
            completionHandler()
        })
    }
    
    private func makeOrRemakeConstraints(viewController: BaseContentViewController, closure:(make: ConstraintMaker) -> Void) {
        if viewController.view.constraints.count > 0 {
            viewController.view.snp_remakeConstraints(closure: closure)
        } else {
            viewController.view.snp_makeConstraints(closure: closure)
        }
    }
    
    private enum ContentViewSide {
        case Left, Right
    }
}

class NavigationControllerBackup: NSViewController {
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
        
//        navigationBarController = NavigationBarController(navigationController: self)
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
//        Notifications.subscribe(observer: self, selector: "pushViewControllerNotification:", name: Notifications.PushViewController, object: nil)
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
            return [NSViewControllerTransitionOptions.SlideRight, NSViewControllerTransitionOptions.Crossfade]
        } else {
            return [NSViewControllerTransitionOptions.SlideLeft, NSViewControllerTransitionOptions.Crossfade]
        }
    }
}
