import Cocoa

final class NavigationItem: NSObject {
	static func standardBackButtonWithTitle(_ title: String) -> NSButton {
		.init(
			image: .init(systemSymbolName: "chevron.backward", accessibilityDescription: "Back")!,
			target: nil,
			action: nil
		)
	}

	static func standardRightButtonWithOnStateTitle(
		_ onStateTitle: String,
		offStateTitle: String,
		target: AnyObject,
		action: Selector
	) -> NSButton {
		let button = NSButton(
			title: offStateTitle,
			target: nil,
			action: nil
		)
		button.alternateTitle = onStateTitle
		button.setButtonType(.toggle)
		return button
	}

	static func standardTitleDropdownButtonForMenu(_ menu: NSMenu) -> TitleBarPopUpButton {
		let button = TitleBarPopUpButton(frame: .zero, pullsDown: true)
		let buttonCell = TitleBarPopUpButtonCell(textCell: "", pullsDown: true)

		buttonCell.altersStateOfSelectedItem = true
		buttonCell.usesItemFromMenu = true
		buttonCell.arrowPosition = .arrowAtBottom

		button.cell = buttonCell
		button.autoenablesItems = true
		button.preferredEdge = .maxY
		button.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(rawValue: 490), for: .horizontal)
		button.lineBreakMode = .byTruncatingMiddle
		button.menu = menu

		return button
	}

	let title: String
	var rightButton: NSButton?
	var titleView: NSView?

	init(title: String) {
		self.title = title
		super.init()
	}
}
