//
//  PopularPlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/17/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

//class HeatMapPlaylistTableCellView: PlaylistTableCellView {
//    @IBOutlet var heatMap: HeatMapView
//    
//    override func trackChanged() {
//        super.trackChanged()
//        
//        HypeMachineAPI.TrackGraphFor(trackValue, success: {graph in
//            self.heatMap.dataPoints = graph.relativeLast24HourData()
//            self.heatMap.heatMapColor = self.heatMapColorForRank(self.trackValue.rank!)
//        }, failure: {error in
//            println(error)
//        })
//    }
//    
//    func heatMapColorForRank(rank: Int) -> NSColor {
//        let gradient = makeGradient()
//        let location = gradientLocationForRank(rank)
//        return gradient.interpolatedColorAtLocation(location)
//    }
//    
//    func makeGradient() -> NSGradient {
//        let redColor = NSColor(red256: 255, green256: 95, blue256: 82)
//        let redPosition: Double = 0
//        let purpleColor = NSColor(red256: 183, green256: 101, blue256: 212)
//        let purplePosition: Double = 6.0 / 49
//        let darkBlueColor = NSColor(red256: 28, green256: 121, blue256: 219)
//        let darkBluePosition: Double = 13.0 / 49
//        let lightBlueColor = NSColor(red256: 158, green256: 236, blue256: 255)
//        let lightBluePosition: Double = 1
//        return NSGradient(colorsAndLocations: (redColor, redPosition), (purpleColor, purplePosition), (darkBlueColor, darkBluePosition), (lightBlueColor, lightBluePosition))
//    }
//    
//    func gradientLocationForRank(rank: Int) -> Double {
//        return Double(rank - 1) / 49
//    }
//    
//    override func mouseEntered(theEvent: NSEvent!) {
//        super.mouseEntered(theEvent)
//        heatMap.hidden = true
//    }
//    
//    override func mouseExited(theEvent: NSEvent!) {
//        super.mouseExited(theEvent)
//        if playState == PlayState.NotPlaying {
//            heatMap.hidden = false
//        }
//    }
//    
//    override func playStateChanged() {
//        super.playStateChanged()
//        
//        switch playState {
//        case .Playing:
//            heatMap.hidden = true
//        case .Paused:
//            heatMap.hidden = true
//        case .NotPlaying:
//            heatMap.hidden = false
//        }
//    }
//}
