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
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        let knobRect = self.knobRect(flipped: flipped)
        
        let inset: CGFloat = floor(knobRect.size.width / 2) // Floor so we don't end up on a 0.5 pixel and draw weird
        let knobCenterX = knobRect.origin.x + inset
        
        var barFillRect = aRect
        barFillRect.size.width = knobCenterX - inset
        barFillRect.origin.x = inset
        barFillColor.set()
        barFillRect.fill(using: .sourceOver)
        
        var barRect = aRect
        barRect.origin.x = knobCenterX
        barRect.size.width = barRect.size.width - knobCenterX - inset + 2.5
        barColor.set()
        barRect.fill(using: .sourceOver)
    }
    
    override func drawKnob(_ knobRect: NSRect) {
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
}
