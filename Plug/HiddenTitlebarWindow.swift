//
//  MainWindow.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HiddenTitlebarWindow: NSWindow {
	override init(contentRect: NSRect, styleMask aStyle: NSWindow.StyleMask, backing bufferingType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        setup()
    }
    
    func setup() {
		appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
		styleMask = [styleMask, NSWindow.StyleMask.fullSizeContentView]
		titleVisibility = NSWindow.TitleVisibility.hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
    }
}
