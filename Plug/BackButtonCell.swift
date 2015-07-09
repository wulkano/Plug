//
//  BackButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 9/3/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BackButtonCell: SwissArmyButtonCell {
    let normalLeftImage = NSImage(named: "Header-Back-Normal-Left")
    let normalMiddleImage = NSImage(named: "Header-Button-Normal-Middle")
    let normalRightImage = NSImage(named: "Header-Button-Normal-Right")
    
    let mouseDownLeftImage = NSImage(named: "Header-Back-Tap-Left")
    let mouseDownMiddleImage = NSImage(named: "Header-Button-Tap-Middle")
    let mouseDownRightImage = NSImage(named: "Header-Button-Tap-Right")
    
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
        if mouseDown {
            NSDrawThreePartImage(frame, mouseDownLeftImage, mouseDownMiddleImage, mouseDownRightImage, false, NSCompositingOperation.CompositeSourceOver, 1, true)
        } else {
            NSDrawThreePartImage(frame, normalLeftImage, normalMiddleImage, normalRightImage, false, NSCompositingOperation.CompositeSourceOver, 1, true)
        }
    }
    
    override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
        var newFrame = frame
//        newFrame.origin.y -= 1
        newFrame.origin.x += 3
        return super.drawTitle(title, withFrame: newFrame, inView: controlView)
    }
    
    override func cellSizeForBounds(aRect: NSRect) -> NSSize {
        var size = super.cellSizeForBounds(aRect)
        size.width += 2
        return size
    }
}
