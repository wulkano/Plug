import Cocoa
import SnapKit

// swiftlint:disable:next static_operator
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case (let left?, let right?):
		return left < right
	case (nil, _?):
		return true
	default:
		return false
	}
}

// swiftlint:disable:next static_operator
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case (let left?, let right?):
		return left > right
	default:
		return rhs < lhs
	}
}


final class NavigationBarController: NSViewController {
	enum TransitionDirection {
		case leftToRight
		case rightToLeft
	}

	let navigationController: NavigationController

	var items: [NavigationItem]?
	var topItem: NavigationItem? { items?.last }

	var backItem: NavigationItem? {
		if items == nil || items!.count < 2 {
			return nil
		}

		return items![items!.count - 2]
	}

	var backgroundView: NSView!
	var navigationBarView: NSView?

	init?(navigationController: NavigationController) {
		self.navigationController = navigationController
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func pushNavigationItem(_ item: NavigationItem, animated: Bool) {
		if items == nil {
			items = []
		}

		items!.append(item)
		updateNavigationBarViews(animated: animated, direction: .rightToLeft)
	}

	func popNavigationItemAnimated(_ animated: Bool) -> NavigationItem? {
		if items == nil || items!.count <= 1 {
			return nil
		}

		let poppedItem = items!.remove(at: items!.count - 1)
		updateNavigationBarViews(animated: animated, direction: .rightToLeft)
		return poppedItem
	}

	func popToNavigationItem(_ item: NavigationItem, animated: Bool) -> [NavigationItem]? {
		if items == nil || items!.count <= 1 {
			return nil
		}

		var poppedItems = [NavigationItem]()
		let topItemIndex = items!.firstIndex(of: item)

		if topItemIndex == nil {
			return nil
		}

		while items!.count - 1 > topItemIndex {
			poppedItems.append(items!.removeLast())
		}

		updateNavigationBarViews(animated: animated, direction: .rightToLeft)
		return poppedItems
	}

	func setNavigationItems(_ items: [NavigationItem]) {
		self.items = items
		updateNavigationBarViews(animated: false, direction: nil)
	}

	func updateNavigationBarViews(animated: Bool, direction: TransitionDirection?) {
		navigationBarView?.removeFromSuperview()
		navigationBarView = nil
		addNavigationBarViewForCurrentItems()
	}

	func addNavigationBarViewForCurrentItems() {
		let buttonEdgeSpacing: CGFloat = 6
		let titleSpacing: CGFloat = 10
		let buttonYOffset: CGFloat = 6
		let titleYOffset: CGFloat = -1
		let buttonHeight: CGFloat = 21

		navigationBarView = NSView()
		backgroundView.addSubview(navigationBarView!)
		navigationBarView!.snp.makeConstraints { make in
			make.edges.equalTo(backgroundView)
		}

		// Back button section
		var backButton: NSButton?

		if backItem != nil {
			backButton = NavigationItem.standardBackButtonWithTitle(backItem!.title)
			backButton!.target = self
			backButton!.action = #selector(NavigationBarController.backButtonClicked(_:))
			navigationBarView!.addSubview(backButton!)
			backButton!.snp.makeConstraints { make in
				make.top.equalTo(navigationBarView!).offset(buttonYOffset)
				make.left.equalTo(navigationBarView!).offset(buttonEdgeSpacing)
				make.height.equalTo(buttonHeight)
			}
		}

		// Right button section
		if topItem!.rightButton != nil {
			navigationBarView!.addSubview(topItem!.rightButton!)
			topItem!.rightButton!.snp.makeConstraints { make in
				make.top.equalTo(navigationBarView!).offset(buttonYOffset)
				make.right.equalTo(navigationBarView!).offset(-buttonEdgeSpacing)
				make.height.equalTo(buttonHeight)
			}
		}

		// Title section
		let titleView: NSView

		if topItem!.titleView != nil {
			titleView = topItem!.titleView!
		} else {
			titleView = textFieldForTitle(topItem!.title)
		}

		navigationBarView!.addSubview(titleView)
		titleView.snp.makeConstraints { make in
			make.centerX.equalTo(backgroundView)
			make.centerY.equalTo(backgroundView).offset(titleYOffset)

			if backButton != nil {
				make.left.greaterThanOrEqualTo(backButton!.snp.right).offset(titleSpacing)
			} else {
				make.left.greaterThanOrEqualTo(navigationBarView!).offset(titleSpacing)
			}

			if topItem!.rightButton != nil {
				make.right.lessThanOrEqualTo(topItem!.rightButton!.snp.left).offset(-titleSpacing)
			} else {
				make.right.lessThanOrEqualTo(navigationBarView!).offset(-titleSpacing)
			}
		}
	}

	func textFieldForTitle(_ title: String) -> NSTextField {
		let textField = NSTextField()
		textField.isEditable = false
		textField.isSelectable = false
		textField.isBordered = false
		textField.drawsBackground = false
		textField.font = appFont(size: 14, weight: .medium)
		textField.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 490), for: .horizontal)
		textField.lineBreakMode = .byTruncatingMiddle
		textField.stringValue = title
		return textField
	}

	// MARK: NSViewController

	override func loadView() {
		view = NSView(frame: .zero)

		backgroundView = NSVisualEffectView(frame: .zero)
		view.addSubview(backgroundView)
		backgroundView.snp.makeConstraints { make in
			make.edges.equalTo(self.view)
		}

		let borderView = BackgroundBorderView()
		borderView.bottomBorder = true
		borderView.borderColor = .borderColor
		backgroundView.addSubview(borderView)
		borderView.snp.makeConstraints { make in
			make.edges.equalTo(backgroundView)
		}
	}

	// MARK: Actions

	@objc
	func backButtonClicked(_ sender: NSButton) {
		_ = navigationController.popViewControllerAnimated(true)
	}
}
