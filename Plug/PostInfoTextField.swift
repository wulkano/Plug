//
//	PostInfoTextField.swift
//	Plug
//
//	Created by Alex Marchant on 10/9/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PostInfoTextField: NSTextField {
	var postInfoDelegate: PostInfoTextFieldDelegate?
	var trackingArea: NSTrackingArea?
	var mouseInside = false

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

	override func mouseDown(with theEvent: NSEvent) {
		postInfoDelegate?.postInfoTextFieldClicked(self)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		mouseInside = true
		updateText()
	}

	override func mouseExited(with theEvent: NSEvent) {
		mouseInside = false
		updateText()
	}

	func updateText() {
		if mouseInside {
			let contents = NSMutableAttributedString(attributedString: attributedStringValue)
			contents.enumerateAttribute(NSAttributedString.Key.link, in: NSRange(location: 0, length: contents.length), options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired, using: { value, range, _ in
				if value != nil {
					contents.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
				}
			})
			attributedStringValue = contents
		} else {
			let contents = NSMutableAttributedString(attributedString: attributedStringValue)
			contents.enumerateAttribute(NSAttributedString.Key.link, in: NSRange(location: 0, length: contents.length), options: NSAttributedString.EnumerationOptions.longestEffectiveRangeNotRequired, using: { value, range, _ in
				if value != nil {
					contents.addAttribute(NSAttributedString.Key.underlineStyle, value: 0, range: range)
				}
			})
			attributedStringValue = contents
		}
	}
}

protocol PostInfoTextFieldDelegate {
	func postInfoTextFieldClicked(_ sender: AnyObject)
}
