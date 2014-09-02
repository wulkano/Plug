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
    
    func setNewRootViewController(viewController: NSViewController, animated: Bool) {
        addChildViewController(viewController)
        if viewControllers.count > 1 {
            transitionFromViewController(nextTopViewController, toViewController: viewController, animated: animated)
            for controller in viewControllers {
                if controller !== viewController {
                    controller.removeFromParentViewController()
                }
            }
        } else {
            setupView(viewController.view)
        }
    }
    
    func pushViewController(viewController: NSViewController, animated: Bool) {
        addChildViewController(viewController)
        transitionFromViewController(nextTopViewController, toViewController: topViewController, animated: true)
    }
    
    func popViewControllerAnimated(animated: Bool) -> NSViewController? {
        if viewControllers.count == 1 { return nil }
        
        transitionFromViewController(visibleViewController, toViewController: viewControllers[viewControllers.count - 2], animated: true)
        
        var poppedController = topViewController
        poppedController.removeFromParentViewController()
        return poppedController
    }
    
    func popToRootViewControllerAnimated(animated: Bool) -> [NSViewController] {
        transitionFromViewController(visibleViewController, toViewController: rootViewController, animated: true)
        var poppedControllers = [NSViewController]()
        while viewControllers.count > 1 {
            var controller = topViewController
            controller.removeFromParentViewController()
            poppedControllers.append(controller)
        }
        return poppedControllers
    }
    
    func popToViewController(viewController: NSViewController, animated: Bool) -> [NSViewController] {
        let index = find(viewControllers, viewController)
        if index == nil {
            fatalError("Tried to pop to view controller that is not in stack")
        }
        
        transitionFromViewController(visibleViewController, toViewController: viewControllers[index!], animated: true)
        
        var poppedControllers = [NSViewController]()
        while topViewController !== viewController {
            var controller = topViewController
            controller.removeFromParentViewController()
            poppedControllers.append(controller)
        }

        return poppedControllers
    }
    
    // MARK: Private methods
    
    func transitionFromViewController(fromViewController: NSViewController!, toViewController: NSViewController!, animated: Bool) {
        var transitions = transitionOptions(animated)
        setupView(toViewController.view)
        transitionFromViewController(fromViewController, toViewController: toViewController, options: transitions, completionHandler: nil)
        
        let index = find(viewControllers, toViewController)
        navigationBar.title = "\(toViewController.title) - \(index! + 1)"
    }
    
    private func transitionOptions(animated: Bool) -> NSViewControllerTransitionOptions {
        if animated {
            return NSViewControllerTransitionOptions.SlideLeft | NSViewControllerTransitionOptions.Crossfade
        } else {
            return NSViewControllerTransitionOptions.None
        }
    }
    
    private func setupView(view: NSView) {
        view.frame = contentView.bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(view)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view": view])
        contentView.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view": view])
        contentView.addConstraints(constraints)
    }
}
