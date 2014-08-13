//
//  SidebarOverlayView.swift
//  Plug
//
//  Created by Alex Marchant on 8/13/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SidebarOverlayView: NSView {
    let overlayColor = NSColor(red256: 48, green256: 53, blue256: 57)
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
         initialSetup()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSVisualEffectView
    }
    
    func initialSetup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowStatusChanged", name: NSWindowDidBecomeMainNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowStatusChanged", name: NSWindowDidResignMainNotification, object: nil)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        if window != nil && !window!.mainWindow {
            overlayColor.set()
            NSRectFill(dirtyRect)
        }
    }
    
    func windowStatusChanged() {
        needsDisplay = true
    }
}
