//
//  SidebarOverlayView.swift
//  Plug
//
//  Created by Alex Marchant on 8/13/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SidebarOverlayView: NSView {
    let overlayColor = NSColor(red256: 91, green256: 91, blue256: 91)
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
         initialSetup()
    }
    
    deinit {
        Notifications.UnsubscribeAll(self)
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
