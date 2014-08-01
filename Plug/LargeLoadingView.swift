//
//  LargeLoadingView.swift
//  Plug
//
//  Created by Alex Marchant on 7/24/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LargeLoadingView: NSView {
    let spinnerImage = NSImage(named: "Loader-Large")

    init(frame: NSRect) {
        super.init(frame: frame)
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
        var drawPoint = NSMakePoint(bounds.size.width / 2, bounds.size.height / 2)
        drawPoint.x -= spinnerImage.size.width / 2
        drawPoint.y -= spinnerImage.size.height / 2
        spinnerImage.drawAtPoint(drawPoint, fromRect: dirtyRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: 1)
    }
    
}
