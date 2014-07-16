//
//  Track.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Track: NSObject {
    var artist: String = "N/A"
    var title: String = "N/A"
    var lovedCount: Int = 0 {
    didSet {
        formattedLovedCount = formatLovedCount(lovedCount)
    }
    }
    var formattedLovedCount: String = "0"
    
    init(JSON json: NSDictionary) {
        super.init()
        
        if json["artist"] {
            artist = json["artist"] as String
        }
        if json["title"] {
            title = json["title"] as String
        }
        if json["loved_count"] {
            lovedCount = json["loved_count"] as Int
            formattedLovedCount = formatLovedCount(json["loved_count"] as Int)
        }
    }
    
    func formatLovedCount(count: Int) -> String {
        if count >= 1000 {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.format = "####K"
            let abbrLovedCount = Double(count) / 1000
            return numberFormatter.stringFromNumber(abbrLovedCount)
        } else {
            return String(count)
        }
    }
}
