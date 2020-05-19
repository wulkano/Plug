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
    
    fileprivate var _viewControllers: [BaseContentViewController]
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
        self.navigationBarController.view.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        self.contentView = NSView(frame: NSZeroRect)
        self.view.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.navigationBarController.view.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    func pushViewController(_ viewController: BaseContentViewController, animated: Bool) {
        guard viewController.parent == nil else {
            fatalError("Pushed view controller already has parent view controller")
        }
        
        self._viewControllers.append(viewController)
		self.addChild(viewController)
        self.updateVisibleViewControllerAnimated(animated)
        
        self.navigationBarController.pushNavigationItem(viewController.navigationItem, animated: animated)
    }
    
    func popViewControllerAnimated(_ animated: Bool) -> BaseContentViewController? {
        guard self.viewControllers.count > 1 else {
            print("Can't pop last view controller")
            return nil
        }
        
        let poppedViewControllerIndex = self._viewControllers.count - 1
        let poppedViewController = self._viewControllers[poppedViewControllerIndex]
        self._viewControllers.remove(at: poppedViewControllerIndex)
		poppedViewController.removeFromParent()
        self.updateVisibleViewControllerAnimated(animated)
        
        self.navigationBarController.popNavigationItemAnimated(animated)
        
        return poppedViewController
    }
    
    func setViewControllers(_ newViewControllers: [BaseContentViewController], animated: Bool) {
        guard newViewControllers.count > 0 else {
            fatalError("Can't set viewControllers to empty array")
        }
        
		self._viewControllers.forEach { $0.removeFromParent() }
        self._viewControllers = newViewControllers
		self._viewControllers.forEach { self.addChild($0) }
        
        self.updateVisibleViewControllerAnimated(animated)
        
        self.navigationBarController.setNavigationItems(newViewControllers.map {$0.navigationItem})
    }
    
    // MARK: Private
    
    fileprivate func updateVisibleViewControllerAnimated(_ animated: Bool) {
        let newVisibleViewController = self.topViewController
        let oldVisibleViewController = self.visibleViewController
        
        guard newVisibleViewController != oldVisibleViewController else {
            print("No need to call updateVisibleViewControllerAnimated here")
            return
        }

        self.contentView.addSubview(newVisibleViewController.view)
        
        if animated {
			let isPushing = self._viewControllers.firstIndex(of: oldVisibleViewController) != nil
            self.constrainViewControllerToSideOfContentView(newVisibleViewController, side: isPushing ? .right : .left)
            self.contentView.layoutSubtreeIfNeeded()
            self.constrainViewControllerToContentView(newVisibleViewController)
            self.constrainViewControllerToSideOfContentView(oldVisibleViewController, side: isPushing ? .left : .right)
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
    
    fileprivate func constrainViewControllerToContentView(_ viewController: BaseContentViewController) {
        let closure = { (make: ConstraintMaker)->Void in
            make.edges.equalTo(self.contentView)
        }
        self.makeOrRemakeConstraints(viewController, closure: closure)
    }
    
    fileprivate func constrainViewControllerToSideOfContentView(_ viewController: BaseContentViewController, side: ContentViewSide) {
        let closure = { (make: ConstraintMaker)->Void in
            make.top.bottom.width.equalTo(self.contentView)
            switch side {
            case .left:
                make.right.equalTo(self.contentView.snp.left)
            case .right:
                make.left.equalTo(self.contentView.snp.right)
            }
        }
        self.makeOrRemakeConstraints(viewController, closure: closure)
    }
    
    fileprivate func startAnimation(completionHandler: @escaping ()->Void) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
			context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.contentView.layoutSubtreeIfNeeded()
        }, completionHandler: {
            completionHandler()
        })
    }
    
    fileprivate func makeOrRemakeConstraints(_ viewController: BaseContentViewController, closure:(_ make: ConstraintMaker) -> Void) {
        if viewController.view.constraints.count > 0 {
            viewController.view.snp.remakeConstraints(closure)
        } else {
            viewController.view.snp.makeConstraints(closure)
        }
    }
    
    fileprivate enum ContentViewSide {
        case left, right
    }
}
