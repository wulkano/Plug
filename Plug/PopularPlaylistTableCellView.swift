//
//  PopularPlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/17/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PopularPlaylistTableCellView: PlaylistTableCellView {
    @IBOutlet var heatMap: PopularHeatMapView
    
    override var objectValue: AnyObject! {
    didSet {
        let track = objectValue as? Track
        if track {
            HypeMachineAPI.TrackGraphFor(track!, success: {graph in
                self.heatMap.dataPoints = graph.relativeLast24HourData()
                self.heatMap.heatMapColor = self.heatMapColorForRank(track!.rank!)
            }, failure: {error in
                println(error)
            })
        }
    }
    }
    
    func heatMapColorForRank(rank: Int) -> NSColor {
        let gradient = makeGradient()
        let location = gradientLocationForRank(rank)
        return gradient.interpolatedColorAtLocation(location)
    }
    
    func makeGradient() -> NSGradient {
        let redColor = NSColor(red256: 255, green256: 95, blue256: 82)
        let redPosition: Double = 0
        let purpleColor = NSColor(red256: 183, green256: 101, blue256: 212)
        let purplePosition: Double = 6.0 / 49
        let darkBlueColor = NSColor(red256: 28, green256: 121, blue256: 219)
        let darkBluePosition: Double = 13.0 / 49
        let lightBlueColor = NSColor(red256: 158, green256: 236, blue256: 255)
        let lightBluePosition: Double = 1
        return NSGradient(colorsAndLocations: (redColor, redPosition), (purpleColor, purplePosition), (darkBlueColor, darkBluePosition), (lightBlueColor, lightBluePosition))
    }
    
    func gradientLocationForRank(rank: Int) -> Double {
        return Double(rank - 1) / 49
    }
}
