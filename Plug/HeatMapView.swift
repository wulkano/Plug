//
//	PopularHeatMapView.swift
//	Plug
//
//	Created by Alexander Marchant on 7/16/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HeatMapView: NSView {
	var heatMap: HeatMap? {
		didSet { needsDisplay = true }
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		if heatMap != nil {
			drawHeatMap(dirtyRect)
		}
	}

	func drawHeatMap(_ dirtyRect: NSRect) {
		let bottomLeftPoint = NSPoint.zero
		let topLeftPoint = NSPoint(x: 0, y: frame.height * CGFloat(heatMap!.start))
		let topRightPoint = NSPoint(x: frame.width, y: frame.height * CGFloat(heatMap!.end))
		let bottomRightPoint = NSPoint(x: frame.width, y: 0)

		let path = NSBezierPath()
		path.move(to: bottomLeftPoint)
		path.line(to: topLeftPoint)
		path.line(to: topRightPoint)
		path.line(to: bottomRightPoint)
		path.close()

		fillColor().set()
		path.fill()
	}

	func fillColor() -> NSColor {
		let gradient = makeGradient()
		let gradientLocation = gradientLocationForRank()
		return gradient.interpolatedColor(atLocation: gradientLocation)
	}

	func gradientLocationForRank() -> CGFloat {
		let rank = heatMap!.track.rank!
		let location = CGFloat(rank) / 50
		return location
	}

	func makeGradient() -> NSGradient {
		let redColor = NSColor(red256: 255, green256: 95, blue256: 82)
		let purpleColor = NSColor(red256: 183, green256: 101, blue256: 212)
		let darkBlueColor = NSColor(red256: 28, green256: 121, blue256: 219)
		let lightBlueColor = NSColor(red256: 158, green256: 236, blue256: 255)
		return NSGradient(colorsAndLocations: (redColor, 0), (purpleColor, 0.333), (darkBlueColor, 0.666), (lightBlueColor, 1))!
	}
}
