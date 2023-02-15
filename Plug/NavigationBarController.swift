import Cocoa
import SnapKit

// swiftlint:disable:next static_operator
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case (let left?, let right?):
		left < right
	case (nil, _?):
		true
	default:
		false
	}
}

// swiftlint:disable:next static_operator
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case (let left?, let right?):
		left > right
	default:
		rhs < lhs
	}
}


final class NavigationBarController: NSViewController {
	enum TransitionDirection {
		case leftToRight
		case rightToLeft
	}

	let navigationController: NavigationController

	var items: [NavigationItem]? // swiftlint:disable:this discouraged_optional_collection
	var topItem: NavigationItem? { items?.last }

	var backItem: NavigationItem? {
		if items == nil || items!.count < 2 {
			return nil
		}

		return items![items!.count - 2]
	}

	var backgroundView: NSView!
	var navigationBarView: NSView?

	init(navigationController: NavigationController) {
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

	// swiftlint:disable:next discouraged_optional_collection
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
		navigationBarView = NSView()
		backgroundView.addSubview(navigationBarView!)
		navigationBarView!.snp.makeConstraints { make in
			make.edges.equalTo(backgroundView)
		}

		var items = [NSToolbarItem]()
		if let titleView = topItem?.titleView {
			items = [
				.flexibleSpace,
				.centeredView(titleView),
				.flexibleSpace
			]
		} else {
			items = [
				.flexibleSpace,
				.centeredTitle(topItem!.title),
				.flexibleSpace
			]
		}

		if let backItem {
			let backButton = NavigationItem.standardBackButtonWithTitle(backItem.title)
			backButton.target = self
			backButton.action = #selector(backButtonClicked(_:))
			items.prepend(.view(identifier: .init("backButton"), view: backButton))
		}

		if let rightButton = topItem?.rightButton {
			items.append(.view(identifier: .init("rightButton"), view: rightButton))
		}

		view.window?.toolbar = .staticToolbar(items)
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
			make.edges.equalTo(view)
		}

		let borderView = BackgroundBorderView()
		borderView.bottomBorder = true
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
