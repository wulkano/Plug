//
//  NavigationController.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa
import SnapKit

// TODO: View controller should only remove parent after view is removed

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
        
        Analytics.trackView(newVisibleViewController.analyticsViewName)
        
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
