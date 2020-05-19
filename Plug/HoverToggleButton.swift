//
//	ToggleButton.swift
//	Plug
//
//	Created by Alexander Marchant on 7/18/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HoverToggleButton: NSButton {
	@IBInspectable var onImage: NSImage?
	@IBInspectable var onHoverImage: NSImage?
	@IBInspectable var offImage: NSImage?
	@IBInspectable var offHoverImage: NSImage?

	var trackingArea: NSTrackingArea?
	var mouseInside: Bool = false {
		didSet { needsDisplay = true }
	}

	var selected: Bool = false {
		didSet { needsDisplay = true }
	}

	override func draw(_ dirtyRect: NSRect) {
		let drawImage = getDrawImage()

		var drawPosition = bounds
		if drawImage != nil {
			drawPosition.origin.x = (bounds.size.width - drawImage!.size.width) / 2
			drawPosition.origin.y = -(bounds.size.height - drawImage!.size.height) / 2
		}

		drawImage?.draw(in: drawPosition, from: dirtyRect, operation: NSCompositingOperation.sourceOver, fraction: 1, respectFlipped: true, hints: nil)
	}

	func getDrawImage() -> NSImage? {
		if selected && mouseInside {
			return onHoverImage
		} else if selected {
			return onImage
		} else if mouseInside {
			return offHoverImage
		} else {
			return offImage
		}
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		updateTrackingAreas()
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if trackingArea != nil {
			removeTrackingArea(trackingArea!)
			trackingArea = nil
		}

		let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseEnteredAndExited]
		trackingArea = NSTrackingArea(rect: NSRect.zero, options: options, owner: self, userInfo: nil)
		addTrackingArea(trackingArea!)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		mouseInside = true
	}

	override func mouseExited(with theEvent: NSEvent) {
		mouseInside = false
	}
}
