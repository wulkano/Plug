//
//	TitleBarPopUpButton.swift
//	Plug
//
//	Created by Alex Marchant on 6/10/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class TitleBarPopUpButtonCell: NSPopUpButtonCell {
	var originalMenu: NSMenu?

	override var menu: NSMenu? {
		didSet {
			originalMenu = menu!.copy() as? NSMenu
		}
	}

	var trimPaddingBetweenArrowAndTitle: CGFloat = 5

	var formattedTitle: NSAttributedString {
		DropdownTitleFormatter().attributedDropdownTitle(menu!.title, optionTitle: title)
	}

	var extraWidthForFormattedTitle: CGFloat {
		formattedTitle.size().width - attributedTitle.size().width
	}

	var extraHeightForFormattedTitle: CGFloat {
		formattedTitle.size().height - attributedTitle.size().height
	}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
		var newFrame = frame
		newFrame.size.width += trimPaddingBetweenArrowAndTitle
		newFrame.size.height += 4
		newFrame.origin.y -= 1
		return super.drawTitle(formattedTitle, withFrame: newFrame, in: controlView)
	}

	override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
		drawArrow(frame, inView: controlView)
	}

	fileprivate func drawArrow(_ frame: NSRect, inView controlView: NSView) {
		let arrowColor = NSColor(white: 0, alpha: 0.4)

		let path = NSBezierPath()
		let bounds = controlView.bounds

		let leftPoint = NSPoint(x: bounds.size.width - 14, y: (bounds.size.height / 2) - 2)
		let bottomPoint = NSPoint(x: bounds.size.width - 10, y: (bounds.size.height / 2) + 2.5)
		let rightPoint = NSPoint(x: bounds.size.width - 6, y: (bounds.size.height / 2) - 2)

		path.move(to: leftPoint)
		path.line(to: bottomPoint)
		path.line(to: rightPoint)

		arrowColor.set()
		path.lineWidth = 2
		path.stroke()
	}


	override func select(_ item: NSMenuItem?) {
		super.select(item)
		sortMenuForSelectedItem(item)
	}

	fileprivate func sortMenuForSelectedItem(_ item: NSMenuItem?) {
		let originalMenuItems = originalMenu!.items
		let sortedItemArray = originalMenuItems.map { self.menu!.item(withTitle: $0.title)! }

		for sortItem in Array(sortedItemArray.reversed()) {
			if sortItem === item! { continue }

			menu!.removeItem(sortItem)
			menu!.insertItem(sortItem, at: 0)
		}

		menu!.removeItem(item!)
		menu!.insertItem(item!, at: 0)
	}
}
