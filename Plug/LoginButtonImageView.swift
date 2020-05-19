//
//	LoginImageView.swift
//	Plug
//
//	Created by Alex Marchant on 8/28/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginButtonImageView: NSImageView {
	override var allowsVibrancy: Bool {
		true
	}

	var alpha: CGFloat = 1

	override func draw(_ dirtyRect: NSRect) {
		if image != nil {
			image!.draw(in: dirtyRect, from: NSRect.zero, operation: NSCompositingOperation.sourceOver, fraction: alpha)
		}
	}
}
