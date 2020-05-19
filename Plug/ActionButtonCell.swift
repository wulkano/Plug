//
//  ActionButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 6/16/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class ActionButtonCell: SwissArmyButtonCell {
    let horizontalPadding: CGFloat = 0

    let onStateColor = NSColor(red256: 255, green256: 95, blue256: 82)
    let offStateColor = NSColor(red256: 44, green256: 144, blue256: 251)

    let normalLeftImage = NSImage(named: "Header-Button-Normal-Left")
    let normalMiddleImage = NSImage(named: "Header-Button-Normal-Middle")
    let normalRightImage = NSImage(named: "Header-Button-Normal-Right")

    let mouseDownLeftImage = NSImage(named: "Header-Button-Tap-Left")
    let mouseDownMiddleImage = NSImage(named: "Header-Button-Tap-Middle")
    let mouseDownRightImage = NSImage(named: "Header-Button-Tap-Right")

    var offStateTitle: String = "" {
        didSet { updateTitle() }
    }
    var onStateTitle: String = "" {
        didSet { updateTitle() }
    }

    override var state: NSControl.StateValue {
        didSet { updateTitle() }
    }

    func updateTitle() {
		if state == .off {
            title = offStateTitle
        } else {
            title = onStateTitle
        }
    }

    var formattedTitle: NSAttributedString {
        var attributes = [NSAttributedString.Key: Any]()

		if state == .off {
			attributes[.foregroundColor] = offStateColor
        } else {
			attributes[.foregroundColor] = onStateColor
        }

		attributes[.font] = appFont(size: 13, weight: .medium)

        return NSAttributedString(string: title, attributes: attributes)
    }

    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        if mouseDown {
            NSDrawThreePartImage(frame, mouseDownLeftImage, mouseDownMiddleImage, mouseDownRightImage, false, NSCompositingOperation.sourceOver, 1, true)
        } else {
            NSDrawThreePartImage(frame, normalLeftImage, normalMiddleImage, normalRightImage, false, NSCompositingOperation.sourceOver, 1, true)
        }
    }

    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        var newFrame = frame
        newFrame.origin.y += 1
        newFrame.origin.x += horizontalPadding
        return super.drawTitle(formattedTitle, withFrame: newFrame, in: controlView)
    }
}
