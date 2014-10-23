//
//  NavigationController.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa

class NavigationController: NSViewController {
    @IBOutlet var navigationBar: NavigationBar!
    @IBOutlet var contentView: NSView!

    var viewControllers: [BaseContentViewController] {
        return childViewControllers as [BaseContentViewController]
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.wantsLayer = true
    }
    
    func setNewRootViewController(viewController: BaseContentViewController) {
        
        if rootViewController == nil {
            addChildViewController(viewController)
            ViewPlacementHelper.AddFullSizeSubview(viewController.view, toSuperView: contentView)
        } else {
            addChildViewController(viewController)
            transitionFromViewController(nextTopViewController, toViewController: viewController, reversed: false)
            removeAllViewControllersExcept(viewController)
        }
        
        Analytics.sharedInstance.trackView(visibleViewController.analyticsViewName)
        updateNavigationBar()
    }
    
    func pushViewController(viewController: BaseContentViewController) {
        addChildViewController(viewController)
        transitionFromViewController(nextTopViewController, toViewController: topViewController, reversed: false)
        
        Analytics.sharedInstance.trackView(visibleViewController.analyticsViewName)
        updateNavigationBar()
    }
    
    func popViewController() -> BaseContentViewController? {
        if !canPopViewController() { return nil }
        
        transitionFromViewController(visibleViewController, toViewController: nextTopViewController!, reversed: true)
        var poppedController = removeTopViewController()
        
        Analytics.sharedInstance.trackView(visibleViewController.analyticsViewName)
        updateNavigationBar()
        
        return poppedController
    }
    
    func popToRootViewController() -> [BaseContentViewController] {
        return popToViewController(rootViewController)
    }
    
    func popToViewController(viewController: BaseContentViewController) -> [BaseContentViewController] {
        if !canPopViewController() { return [] }
        if !canPopToViewController(viewController) { return [] }
        
        transitionFromViewController(visibleViewController, toViewController: viewController,  reversed: true)
        var poppedControllers = removeViewControllersAbove(viewController)
        
        Analytics.sharedInstance.trackView(visibleViewController.analyticsViewName)
        updateNavigationBar()
        
        return poppedControllers
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        popViewController()
    }
    
    // MARK: Private methods
    
    private func removeViewControllersAbove(viewController: BaseContentViewController) -> [BaseContentViewController] {
        var removedControllers = [BaseContentViewController]()
        while topViewController !== viewController {
            var controller = topViewController
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
        var poppedController = topViewController
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
        var transitions = transitionOptions(reversed)
        ViewPlacementHelper.AddFullSizeSubview(toViewController.view, toSuperView: contentView)
        transitionFromViewController(fromViewController, toViewController: toViewController, options: transitions, completionHandler: nil)
        
        if fromViewController != nil { fromViewController.didLoseCurrentViewController() }
        toViewController.didBecomeCurrentViewController()
    }
    
    private func transitionOptions(reversed: Bool) -> NSViewControllerTransitionOptions {
        if reversed {
            return NSViewControllerTransitionOptions.SlideRight | NSViewControllerTransitionOptions.Crossfade
        } else {
            return NSViewControllerTransitionOptions.SlideLeft | NSViewControllerTransitionOptions.Crossfade
        }
    }
    
    private func updateNavigationBar() {
        navigationBar.previousViewControllerUpdated(nextTopViewController)
        navigationBar.currentViewControllerUpdated(topViewController)
    }
}
