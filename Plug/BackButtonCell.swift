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
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        if mouseDown {
            NSDrawThreePartImage(frame, mouseDownLeftImage, mouseDownMiddleImage, mouseDownRightImage, false, NSCompositingOperation.sourceOver, 1, true)
        } else {
            NSDrawThreePartImage(frame, normalLeftImage, normalMiddleImage, normalRightImage, false, NSCompositingOperation.sourceOver, 1, true)
        }
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        var newFrame = frame
        newFrame.origin.y += 1
        newFrame.origin.x += 3
        return super.drawTitle(title, withFrame: newFrame, in: controlView)
    }
    
    override func cellSize(forBounds aRect: NSRect) -> NSSize {
        var size = super.cellSize(forBounds: aRect)
        size.width += 2
        return size
    }
}
