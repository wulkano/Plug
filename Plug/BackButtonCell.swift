//
//  BackButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 9/3/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BackButtonCell: SwissArmyButtonCell {
    var normalLeftImage = NSImage(named: "Header-Back-Normal-Left")
    var normalMiddleImage = NSImage(named: "Header-Back-Normal-Middle")
    var normalRightImage = NSImage(named: "Header-Back-Normal-Right")
    
    var mouseDownLeftImage = NSImage(named: "Header-Back-Tap-Left")
    var mouseDownMiddleImage = NSImage(named: "Header-Back-Tap-Middle")
    var mouseDownRightImage = NSImage(named: "Header-Back-Tap-Right")
    
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
        if mouseDown {
            NSDrawThreePartImage(frame, mouseDownLeftImage, mouseDownMiddleImage, mouseDownRightImage, false, NSCompositingOperation.CompositeSourceOver, 1, true)
        } else {
            NSDrawThreePartImage(frame, normalLeftImage, normalMiddleImage, normalRightImage, false, NSCompositingOperation.CompositeSourceOver, 1, true)
        }
    }
    
    override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
        var newFrame = frame
        newFrame.origin.y -= 2
        newFrame.origin.x += 3
        return super.drawTitle(title, withFrame: newFrame, inView: controlView)
    }
    
    override func cellSizeForBounds(aRect: NSRect) -> NSSize {
        var size = super.cellSizeForBounds(aRect)
        size.width += 15
        return size
    }
}
