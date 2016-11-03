//
//  MainWindow.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HiddenTitlebarWindow: NSWindow {
    override init(contentRect: NSRect, styleMask aStyle: NSWindowStyleMask, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        
        setup()
    }
    
    func setup() {
        appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        styleMask = [styleMask, NSWindowStyleMask.fullSizeContentView]
        titleVisibility = NSWindowTitleVisibility.hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
    }
}
