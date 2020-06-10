import Cocoa
import SnapKit

// TODO: View controller should only remove parent after view is removed.

final class NavigationController: NSViewController {
	static var shared: NavigationController?

	private var _viewControllers: [BaseContentViewController]
	var viewControllers: [BaseContentViewController] {
		get { _viewControllers }
		set {
			setViewControllers(newValue, animated: false)
		}
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

		self.visibleViewController = _viewControllers.first!

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		view = NSView(frame: .zero)

		navigationBarController = NavigationBarController(navigationController: self)
		view.addSubview(navigationBarController.view)
		navigationBarController.view.snp.makeConstraints { make in
			make.height.equalTo(36)
			make.top.equalTo(view)
			make.left.equalTo(view)
			make.right.equalTo(view)
		}

		contentView = NSView(frame: .zero)
		view.addSubview(contentView)
		contentView.snp.makeConstraints { make in
			make.top.equalTo(navigationBarController.view.snp.bottom)
			make.left.equalTo(view)
			make.bottom.equalTo(view)
			make.right.equalTo(view)
		}
	}

	func pushViewController(_ viewController: BaseContentViewController, animated: Bool) {
		guard viewController.parent == nil else {
			fatalError("Pushed view controller already has parent view controller")
		}

		_viewControllers.append(viewController)
		addChild(viewController)
		updateVisibleViewControllerAnimated(animated)

		navigationBarController.pushNavigationItem(viewController.navigationItem, animated: animated)
	}

	func popViewControllerAnimated(_ animated: Bool) -> BaseContentViewController? {
		guard viewControllers.count > 1 else {
			print("Can't pop last view controller")
			return nil
		}

		let poppedViewControllerIndex = _viewControllers.count - 1
		let poppedViewController = _viewControllers[poppedViewControllerIndex]
		_viewControllers.remove(at: poppedViewControllerIndex)
		poppedViewController.removeFromParent()
		updateVisibleViewControllerAnimated(animated)

		_ = navigationBarController.popNavigationItemAnimated(animated)

		return poppedViewController
	}

	func setViewControllers(_ newViewControllers: [BaseContentViewController], animated: Bool) {
		guard !newViewControllers.isEmpty else {
			fatalError("Can't set viewControllers to empty array")
		}

		_viewControllers.forEach {
			$0.removeFromParent()
		}

		_viewControllers = newViewControllers

		_viewControllers.forEach {
			addChild($0)
		}

		updateVisibleViewControllerAnimated(animated)

		navigationBarController.setNavigationItems(newViewControllers.map { $0.navigationItem })
	}

	// MARK: Private

	private func updateVisibleViewControllerAnimated(_ animated: Bool) {
		let newVisibleViewController = topViewController
		let oldVisibleViewController = visibleViewController

		guard newVisibleViewController != oldVisibleViewController else {
			print("No need to call updateVisibleViewControllerAnimated here")
			return
		}

		contentView.addSubview(newVisibleViewController.view)

		if animated {
			let isPushing = viewControllers.contains(oldVisibleViewController)
			constrainViewControllerToSideOfContentView(newVisibleViewController, side: isPushing ? .right : .left)
			contentView.layoutSubtreeIfNeeded()
			constrainViewControllerToContentView(newVisibleViewController)
			constrainViewControllerToSideOfContentView(oldVisibleViewController, side: isPushing ? .left : .right)

			startAnimation {
				oldVisibleViewController.view.removeFromSuperview()
			}
		} else {
			constrainViewControllerToContentView(newVisibleViewController)
			oldVisibleViewController.view.removeFromSuperview()
		}

		Analytics.trackView(newVisibleViewController.analyticsViewName)

		visibleViewController = newVisibleViewController
	}

	private func constrainViewControllerToContentView(_ viewController: BaseContentViewController) {
		let closure = { (make: ConstraintMaker) -> Void in
			make.edges.equalTo(self.contentView)
		}

		makeOrRemakeConstraints(viewController, closure: closure)
	}

	private func constrainViewControllerToSideOfContentView(_ viewController: BaseContentViewController, side: ContentViewSide) {
		let closure = { (make: ConstraintMaker) -> Void in
			make.top.bottom.width.equalTo(self.contentView)
			switch side {
			case .left:
				make.right.equalTo(self.contentView.snp.left)
			case .right:
				make.left.equalTo(self.contentView.snp.right)
			}
		}

		makeOrRemakeConstraints(viewController, closure: closure)
	}

	private func startAnimation(completionHandler: @escaping () -> Void) {
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.25
			context.allowsImplicitAnimation = true
			context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
			self.contentView.layoutSubtreeIfNeeded()
		}, completionHandler: {
			completionHandler()
		})
	}

	private func makeOrRemakeConstraints(_ viewController: BaseContentViewController, closure: (_ make: ConstraintMaker) -> Void) {
		if !viewController.view.constraints.isEmpty {
			viewController.view.snp.remakeConstraints(closure)
		} else {
			viewController.view.snp.makeConstraints(closure)
		}
	}

	private enum ContentViewSide {
		case left
		case right
	}
}
