//
//	NavigationItem.swift
//	Plug
//
//	Created by Alex Marchant on 7/15/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

final class NavigationItem: NSObject {
	var title: String
	var rightButton: ActionButton?
	var titleView: NSView?

	init(title: String) {
		self.title = title
		super.init()
	}

	static func standardBackButtonWithTitle(_ title: String) -> SwissArmyButton {
		let button = SwissArmyButton(frame: CGRect.zero)
		let cell = BackButtonCell(textCell: "")
		button.cell = cell
		button.bezelStyle = .regularSquare
		button.isBordered = true
		button.font = appFont(size: 13, weight: .medium)
		button.title = title

		return button
	}

	static func standardRightButtonWithOnStateTitle(_ onStateTitle: String, offStateTitle: String, target: AnyObject, action: Selector) -> ActionButton {
		let button = ActionButton(frame: CGRect.zero)
		let cell = ActionButtonCell(textCell: "")

		button.cell = cell
		button.onStateTitle = onStateTitle
		button.offStateTitle = offStateTitle
		button.state = .off
		button.bezelStyle = .regularSquare
		button.isBordered = true
		button.font = appFont(size: 13, weight: .medium)
		button.target = target
		button.action = action

		return button
	}

	static func standardTitleDropdownButtonForMenu(_ menu: NSMenu) -> TitleBarPopUpButton {
		let button = TitleBarPopUpButton(frame: CGRect.zero, pullsDown: true)
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
}
