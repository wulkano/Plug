//
//  TitleBarPopUpButton.swift
//  Plug
//
//  Created by Alex Marchant on 6/10/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class TitleBarPopUpButtonCell: NSPopUpButtonCell {

    override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
        println(self.title)
        println(title)
//        let newString = NSMutableAttributedString(string: "\(title)")
        return super.drawTitle(title, withFrame: frame, inView: controlView)
    }
    
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
        let arrowColor = NSColor(white: 0, alpha: 0.4)
        
        let path = NSBezierPath()
        let bounds = controlView.bounds
        
        let leftPoint = NSMakePoint(bounds.size.width - 14, (bounds.size.height / 2) - 1)
        let bottomPoint = NSMakePoint(bounds.size.width - 10, (bounds.size.height / 2) + 3.5);
        let rightPoint = NSMakePoint(bounds.size.width - 6, (bounds.size.height / 2) - 1);
        
        path.moveToPoint(leftPoint)
        path.lineToPoint(bottomPoint)
        path.lineToPoint(rightPoint)
        
        arrowColor.set()
        path.lineWidth = 2
        path.stroke()
    }
}