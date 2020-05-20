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

	override func draw(_ dirtyRect: CGRect) {
		if image != nil {
			image!.draw(in: dirtyRect, from: CGRect.zero, operation: NSCompositingOperation.sourceOver, fraction: alpha)
		}
	}
}
