//
//  PopularHeatMapView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PopularHeatMapView: NSView {
    var dataPoints: (Double, Double)? {
    didSet {
        needsDisplay = true
    }
    }
    var heatMapColor: NSColor? {
    didSet {
        needsDisplay = true
    }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        if dataPoints && heatMapColor {
            drawHeatMap(dirtyRect)
        }
    }
    
    func drawHeatMap(dirtyRect: NSRect) {
        let heatMapSideLength: Double = 32
        
        let xOffset = (bounds.size.width - heatMapSideLength) / 2
        let yOffset = (bounds.size.height - heatMapSideLength) / 2
        let heatMapOrigin = NSMakePoint(xOffset, yOffset)
        
        let thePath = NSBezierPath()
        thePath.moveToPoint(heatMapOrigin)
        thePath.lineToPoint(NSMakePoint(heatMapOrigin.x, heatMapOrigin.y + heatMapSideLength * dataPoints!.0))
        thePath.lineToPoint(NSMakePoint(heatMapOrigin.x + heatMapSideLength, heatMapOrigin.y + heatMapSideLength * dataPoints!.1))
        thePath.lineToPoint(NSMakePoint(heatMapOrigin.x + heatMapSideLength, heatMapOrigin.y))
        thePath.closePath()
        
        heatMapColor!.set()
        thePath.fill()
    }
}