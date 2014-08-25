//
//  MainWindow.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HiddenTitlebarWindow: NSWindow {
    @IBInspectable var visibleTitleText: Bool = false
    
    override init(contentRect: NSRect, styleMask aStyle: Int, backing bufferingType: NSBackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: aStyle, backing: bufferingType, defer: flag)
        appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        styleMask |= NSFullSizeContentViewWindowMask
        if visibleTitleText {
            titleVisibility = NSWindowTitleVisibility.Visible
        } else {
            titleVisibility = NSWindowTitleVisibility.Hidden
        }
        titlebarAppearsTransparent = true
        movableByWindowBackground = true
    }
    
    required init(coder: NSCoder!) {
        super.init(coder: coder)
    }
}
