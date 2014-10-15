//
//  TrackGraph.swift
//  Plug
//
//  Created by Alexander Marchant on 7/17/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HeatMap: NSObject {
    var track: Track
    var start: Double
    var end: Double
    
    init(track: Track, start: Double, end: Double) {
        self.track = track
        self.start = start
        self.end = end

        super.init()
    }
}
