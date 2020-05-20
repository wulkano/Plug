//
//	SwissArmyButton.swift
//	Plug
//
//	Created by Alex Marchant on 8/28/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SwissArmyButton: NSButton {
	@IBInspectable var vibrant: Bool = false
	@IBInspectable var tracksHover: Bool = false

	override var allowsVibrancy: Bool {
		vibrant
	}

	override var state: NSControl.StateValue {
		didSet { needsDisplay = true }
	}

	var trackingArea: NSTrackingArea?
	var swissArmyButtonCell: SwissArmyButtonCell {
		cell as! SwissArmyButtonCell
	}

	var mouseInside: Bool {
		get { swissArmyButtonCell.mouseInside }
		set { swissArmyButtonCell.mouseInside = newValue }
	}

	var mouseDown: Bool {
		get { swissArmyButtonCell.mouseDown }
		set { swissArmyButtonCell.mouseDown = newValue }
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		updateTrackingAreas()
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if tracksHover {
			if trackingArea != nil {
				removeTrackingArea(trackingArea!)
				trackingArea = nil
			}

			let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseEnteredAndExited]
			trackingArea = NSTrackingArea(rect: CGRect.zero, options: options, owner: self, userInfo: nil)
			addTrackingArea(trackingArea!)
		}
	}

	override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	func setup() {
		setupCell()

		isBordered = false
	}

	func setupCell() {
		let newCell = SwissArmyButtonCell(textCell: "")
		cell = newCell
	}

	override func mouseEntered(with theEvent: NSEvent) {
		mouseInside = true
		needsDisplay = true
	}

	override func mouseExited(with theEvent: NSEvent) {
		mouseInside = false
		needsDisplay = true
	}

	override func mouseDown(with theEvent: NSEvent) {
		mouseDown = true
		needsDisplay = true
		super.mouseDown(with: theEvent)
		mouseUp(with: theEvent)
	}

	override func mouseUp(with theEvent: NSEvent) {
		mouseDown = false
		needsDisplay = true
		super.mouseUp(with: theEvent)
	}
}
