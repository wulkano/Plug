//
//	CircleMaskImageView.swift
//	Plug
//
//	Created by Alex Marchant on 9/7/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class CircleMaskImageView: NSImageView {
	override func draw(_ dirtyRect: NSRect) {
		if image != nil {
			NSGraphicsContext.saveGraphicsState()

			let path = NSBezierPath(roundedRect: bounds, xRadius: bounds.size.width / 2, yRadius: bounds.size.height / 2)
			path.addClip()
			image!.draw(in: bounds, from: NSRect.zero, operation: .sourceOver, fraction: 1)

			NSGraphicsContext.restoreGraphicsState()
		}
	}
}
