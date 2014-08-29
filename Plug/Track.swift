//
//  Track.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Track: NSObject {
    var id: String!
    var artist: String!
    var title: String!
    var loved: Bool = false
    var lovedCount: Int!
    var formattedLovedCount: String!
    var thumbURLSmall: NSURL?
    var thumbURLMedium: NSURL?
    var thumbURLLarge: NSURL?
    var rank: Int?
    var playlist: Playlist?
    var lovedBy: String?
    var postedBy: String!
    var postedById: Int!
    var postedCount: Int!
    var postedByDescription: String!
    
    init(JSON json: NSDictionary) {
        super.init()
        
        id = json["itemid"] as String
        artist = json["artist"] as String
        if artist == "" {
            artist = "Unknown artist"
        }
        title = json["title"] as String
        if title == "" {
            title = "Unknown track"
        }
        if json["ts_loved_me"] is Int {
            loved = true
        } else {
            loved = false
        }
        lovedCount = json["loved_count"] as Int
        formattedLovedCount = formatLovedCount(lovedCount)
        if json["thumb_url"] is String {
            thumbURLSmall = NSURL(string: json["thumb_url"] as String)
        }
        if json["thumb_url_medium"] is String {
            thumbURLMedium = NSURL(string: json["thumb_url_medium"] as String)
        }
        if json["thumb_url_large"] is String {
            thumbURLLarge = NSURL(string: json["thumb_url_large"] as String)
        }
        if json["rank"] is Int {
            rank = (json["rank"] as Int)
        }
        if json["via_user"] is String {
            lovedBy = json["via_user"] as? String
        }
        postedBy = json["sitename"] as String
        postedById = json["siteid"] as Int
        postedCount = json["posted_count"] as Int
        postedByDescription = (json["description"] as String) + "..."
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
        var mediaLinkString: String
        if RickRoll {
            mediaLinkString = "https://hypem.com/serve/public/b7wa?key=\(ApiKey)"
        } else {
            mediaLinkString = "https://hypem.com/serve/public/\(id)?key=\(ApiKey)"
        }
        return NSURL(string: mediaLinkString)
    }
    
    func thumbURLWithPreferedSize(size: Track.ImageSize) -> NSURL {
        switch size {
        case .Large:
            if thumbURLLarge != nil {
                return thumbURLLarge!
            } else if thumbURLMedium != nil {
                return thumbURLMedium!
            } else {
                return thumbURLSmall!
            }
        case .Medium:
            if thumbURLMedium != nil {
                return thumbURLMedium!
            } else if thumbURLLarge != nil {
                return thumbURLLarge!
            } else {
                return thumbURLSmall!
            }
        case .Small:
            if thumbURLSmall != nil {
                return thumbURLSmall!
            } else if thumbURLMedium != nil {
                return thumbURLMedium!
            } else {
                return thumbURLLarge!
            }
        }
    }
    
    enum ImageSize {
        case Small
        case Medium
        case Large
    }
}
