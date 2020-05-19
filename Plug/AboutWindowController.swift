//
//	AboutWindowController.swift
//	Plug
//
//	Created by Alex Marchant on 7/15/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {
	convenience init() {
		let aboutWindow = NSWindow(
			contentRect: NSRect.zero,
			styleMask: [NSWindow.StyleMask.titled, NSWindow.StyleMask.miniaturizable, NSWindow.StyleMask.closable],
			backing: NSWindow.BackingStoreType.buffered,
			defer: false
		)
		aboutWindow.contentViewController = AboutViewController(nibName: nil, bundle: nil)
		aboutWindow.center()

		self.init(window: aboutWindow)
	}
}
