//
//  FlatSliderCell.swift
//  Plug
//
//  Created by Alexander Marchant on 7/18/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FlatSliderCell: NSSliderCell {
    @IBInspectable var barColor: NSColor = NSColor(red256: 0, green256: 0, blue256: 0, alpha: 0.1)
    @IBInspectable var barFillColor: NSColor = NSColor(red256: 0, green256: 0, blue256: 0, alpha: 0.3)
    @IBInspectable var knobSize: CGFloat = 12
    @IBInspectable var knobFillColor: NSColor = NSColor(red256: 0, green256: 0, blue256: 0, alpha: 0.3)
    
    var mouseDown: Bool = false
    var mouseInside: Bool = false
    
    override func drawBarInside(aRect: NSRect, flipped: Bool) {
        let knobRect = knobRectFlipped(flipped)
        
        if verticalSlider() {
            // TODO
        } else {
            let inset: CGFloat = knobRect.size.width / 2
            let knobCenterX = knobRect.origin.x + inset
            
            var barFillRect = aRect
            barFillRect.size.width = knobCenterX - inset + 0.5
            barFillRect.origin.x = inset - 0.5
            barFillColor.set()
            NSRectFillUsingOperation(barFillRect, NSCompositingOperation.CompositeSourceOver)
            
            var barRect = aRect
            barRect.origin.x = knobCenterX
            barRect.size.width = barRect.size.width - knobCenterX - inset + 2.5
            barColor.set()
            NSRectFillUsingOperation(barRect, NSCompositingOperation.CompositeSourceOver)
        }
    }
    
    override func drawKnob(knobRect: NSRect) {
//        TODO fix this drawing so it's not overlapping on the bar
//        if mouseInside {
//            var vInset = (knobRect.size.height - knobSize) / 2
//            var hInset = (knobRect.size.width - knobSize) / 2
//            knobFillColor.set()
//            let insetRect = NSInsetRect(knobRect, hInset, vInset)
//            let circlePath = NSBezierPath(ovalInRect: insetRect)
//            circlePath.fill()
//        }
    }
    
    func verticalSlider() -> Bool {
        return (controlView as NSSlider).vertical == 1
    }
}
