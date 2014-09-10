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
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    var viewControllers: [NSViewController] {
        return childViewControllers as [NSViewController]
    }
    var topViewController: NSViewController! {
        return viewControllers.last
    }
    var nextTopViewController: NSViewController? {
        if viewControllers.count > 1 {
            return viewControllers[viewControllers.count - 2]
        } else {
            return nil
        }

    }
    var rootViewController: NSViewController! {
        return viewControllers.first
    }
    var visibleViewController: NSViewController! {
        return topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.wantsLayer = true
    }
    
    func setNewRootViewController(viewController: NSViewController) {
        
        if rootViewController == nil {
            addChildViewController(viewController)
            ViewPlacementHelper.AddFullSizeSubview(viewController.view, toSuperView: contentView)
        } else {
            addChildViewController(viewController)
            transitionFromViewController(nextTopViewController, toViewController: viewController, reversed: false)
            removeAllViewControllersExcept(viewController)
        }
        
        updateNavigationBar()
    }
    
    func pushViewController(viewController: NSViewController) {
        addChildViewController(viewController)
        transitionFromViewController(nextTopViewController, toViewController: topViewController, reversed: false)
        updateNavigationBar()
    }
    
    func popViewController() -> NSViewController? {
        if !canPopViewController() { return nil }
        
        transitionFromViewController(visibleViewController, toViewController: nextTopViewController!, reversed: true)
        var poppedController = removeTopViewController()
        updateNavigationBar()
        
        return poppedController
    }
    
    func popToRootViewController() -> [NSViewController] {
        return popToViewController(rootViewController)
    }
    
    func popToViewController(viewController: NSViewController) -> [NSViewController] {
        if !canPopViewController() { return [] }
        if !canPopToViewController(viewController) { return [] }
        
        transitionFromViewController(visibleViewController, toViewController: viewController,  reversed: true)
        var poppedControllers = removeViewControllersAbove(viewController)
        updateNavigationBar()
        
        return poppedControllers
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        popViewController()
    }
    
    // MARK: Private methods
    
    private func removeViewControllersAbove(viewController: NSViewController) -> [NSViewController] {
        var removedControllers = [NSViewController]()
        while topViewController !== viewController {
            var controller = topViewController
            controller.removeFromParentViewController()
            removedControllers.append(controller)
        }
        return removedControllers
    }
    
    private func removeAllViewControllersExcept(viewController: NSViewController) -> [NSViewController] {
        var removedControllers = [NSViewController]()
        for controller in viewControllers {
            if controller !== viewController {
                controller.removeFromParentViewController()
                removedControllers.append(controller)
            }
        }
        return removedControllers
    }
    
    private func removeTopViewController() -> NSViewController {
        var poppedController = topViewController
        poppedController.removeFromParentViewController()
        return poppedController
    }
    
    private func canPopViewController() -> Bool {
        return viewControllers.count > 1
    }
    
    private func canPopToViewController(viewController: NSViewController) -> Bool {
        return hasChildViewController(viewController)
    }
    
    private func hasChildViewController(viewController: NSViewController) -> Bool {
        return viewController.parentViewController === self
    }
    
    private func transitionFromViewController(fromViewController: NSViewController!, toViewController: NSViewController!, reversed: Bool) {
        var transitions = transitionOptions(reversed)
        ViewPlacementHelper.AddFullSizeSubview(toViewController.view, toSuperView: contentView)
        transitionFromViewController(fromViewController, toViewController: toViewController, options: transitions, completionHandler: nil)
        
        let index = find(viewControllers, toViewController)
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
    
    override func keyDown(theEvent: NSEvent!) {
        switch theEvent.keyCode {
        case 123:
            leftArrowKeyPressed(theEvent)
        default:
            super.keyDown(theEvent)
        }
    }
    
    func leftArrowKeyPressed(theEvent: NSEvent!) {
        if nextTopViewController != nil {
            popViewController()
        } else {
            super.keyDown(theEvent)
        }
    }
}
