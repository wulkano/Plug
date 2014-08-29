//
//  PopularHeatMapView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HeatMapView: NSView {
    var heatMap: HeatMap? {
        didSet { needsDisplay = true }
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        if heatMap != nil {
            drawHeatMap(dirtyRect)
        }
    }
    
    func drawHeatMap(dirtyRect: NSRect) {
        var dataPoints = heatMap!.relativeLast24HourData()
        
        let bottomLeftPoint = NSZeroPoint
        let topLeftPoint = NSMakePoint(0, frame.height * CGFloat(dataPoints.start))
        let topRightPoint = NSMakePoint(frame.width, frame.height * CGFloat(dataPoints.end))
        let bottomRightPoint = NSMakePoint(frame.width, 0)
        
        let path = NSBezierPath()
        path.moveToPoint(bottomLeftPoint)
        path.lineToPoint(topLeftPoint)
        path.lineToPoint(topRightPoint)
        path.lineToPoint(bottomRightPoint)
        path.closePath()
        
        fillColor().set()
        path.fill()
    }
    
    func fillColor() -> NSColor {
        let gradient = makeGradient()
        let gradientLocation = gradientLocationForRank()
        return gradient.interpolatedColorAtLocation(gradientLocation)
    }
    
    func gradientLocationForRank() -> CGFloat {
        var rank = heatMap!.track.rank!
        var location = CGFloat(rank) / 50
        return location
    }
    
    func makeGradient() -> NSGradient {
        let redColor = NSColor(red256: 255, green256: 95, blue256: 82)
        let purpleColor = NSColor(red256: 183, green256: 101, blue256: 212)
        let darkBlueColor = NSColor(red256: 28, green256: 121, blue256: 219)
        let lightBlueColor = NSColor(red256: 158, green256: 236, blue256: 255)
        return NSGradient(colorsAndLocations: (redColor, 0), (purpleColor, 0.333), (darkBlueColor, 0.666), (lightBlueColor, 1))
    }
}