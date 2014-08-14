//
//  Track.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Track: NSObject {
    var id: String = "0"
    var artist: String = "N/A"
    var title: String = "N/A"
    var loved: Bool = false
    var lovedCount: Int = 0 {
    didSet {
        formattedLovedCount = formatLovedCount(lovedCount)
    }
    }
    var formattedLovedCount: String = "0"
    var rank: Int?
    var playlist: Playlist?
    var lovedBy: String?
    
    init(JSON json: NSDictionary) {
        super.init()
        
        if json["itemid"] is String {
            id = json["itemid"] as String
        }
        if json["artist"] is String {
            artist = json["artist"] as String
        }
        if json["title"] is String {
            title = json["title"] as String
        }
        if json["ts_loved_me"] is Int {
            loved = true
        }
        if json["loved_count"] is Int {
            lovedCount = json["loved_count"] as Int
            formattedLovedCount = formatLovedCount(json["loved_count"] as Int)
        }
        if json["rank"] is Int {
            rank = (json["rank"] as Int)
        }
        if json["via_user"] is String {
            lovedBy = (json["via_user"] as String)
        }
    }
    
    func formatLovedCount(count: Int) -> String {
        if count >= 1000 {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.format = "####k"
            let abbrLovedCount = Double(count) / 1000
            return numberFormatter.stringFromNumber(abbrLovedCount)
        } else {
            return String(count)
        }
    }
    
    func mediaURL() -> NSURL {
        var mediaLinkString = "https://hypem.com/serve/public/\(id)?key=\(ApiKey)"
        return NSURL(string: mediaLinkString)
    }
}
