//
//  Track.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Track: NSObject {
    var id: String
    var artist: String
    var title: String
    var loved: Bool = false
    var lovedCount: Int
    var lovedCountNum: NSNumber
    var thumbURLSmall: NSURL?
    var thumbURLMedium: NSURL?
    var thumbURLLarge: NSURL?
    var rank: Int?
    var playlist: Playlist?
    var lovedBy: String?
    var postedBy: String
    var postedById: Int
    var postedCount: Int
    var postedByDescription: String
    var datePosted: NSDate
    var audioUnavailable: Bool = false
    
    init(JSON json: NSDictionary) {
        
        id = json["itemid"] as String
        artist = json["artist"] as? String ?? "Unknown artist"
        if artist == "" { artist = "Unknown artist" }
        title = json["title"] as? String ?? "Unknown track"
        if title == "" { title = "Unknown track" }
        if json["ts_loved_me"] is Int {
            loved = true
        } else {
            loved = false
        }
        lovedCount = json["loved_count"] as Int
        lovedCountNum = NSNumber(integer: lovedCount)
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
        postedByDescription = json["description"] as? String ?? "No description available"
        datePosted = NSDate(timeIntervalSince1970: json["dateposted"] as NSTimeInterval)
        if json["pub_audio_unavail"] is Bool {
            audioUnavailable = true
        }
        
        super.init()
    }
    
    func mediaURL() -> NSURL {
        var mediaLinkString: String
        if RickRoll {
            mediaLinkString = "https://hypem.com/serve/public/b7wa?key=\(ApiKey)"
        } else {
            mediaLinkString = "https://hypem.com/serve/public/\(id)?key=\(ApiKey)"
        }
        return NSURL(string: mediaLinkString)!
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
    
    func hypeMachineURL() -> NSURL {
        return NSURL(string: "http://hypem.com/track/\(id)")!
    }
    
    enum ImageSize {
        case Small
        case Medium
        case Large
    }
}
