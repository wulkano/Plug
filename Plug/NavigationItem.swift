import Cocoa

final class NavigationItem: NSObject {
	static func standardBackButtonWithTitle(_ title: String) -> NSButton {
		let button: NSButton
		if #available(macOS 11, *) {
			button = NSButton(
				image: NSImage(systemSymbolName: "chevron.backward", accessibilityDescription: "Back")!,
				target: nil,
				action: nil
			)
		} else {
			button = SwissArmyButton(frame: .zero)
			let cell = BackButtonCell(textCell: "")
			button.cell = cell
			button.bezelStyle = .regularSquare
			button.isBordered = true
			button.font = .systemFont(ofSize: 11)
			button.title = title
		}

		return button
	}

	static func standardRightButtonWithOnStateTitle(
		_ onStateTitle: String,
		offStateTitle: String,
		target: AnyObject,
		action: Selector
	) -> NSButton {
		let button: NSButton
		if #available(macOS 11, *) {
			button = NSButton(
				title: offStateTitle,
				target: nil,
				action: nil
			)
			button.alternateTitle = onStateTitle
			button.setButtonType(.toggle)
		} else {
			let button2 = ActionButton(frame: .zero)
			let cell = ActionButtonCell(textCell: "")

			button2.cell = cell
			button2.onStateTitle = onStateTitle
			button2.offStateTitle = offStateTitle
			button2.state = .off
			button2.bezelStyle = .regularSquare
			button2.isBordered = true
			button2.font = appFont(size: 13, weight: .medium)
			button2.target = target
			button2.action = action

			button = button2
		}

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
