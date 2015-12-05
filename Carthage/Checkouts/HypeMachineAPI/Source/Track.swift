//
//  Track.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

public final class Track: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable {
    public let id: String
    public let artist: String
    public let title: String
    public let lovedCount: Int
    public let lovedCountNum: NSNumber
    public let thumbURLSmall: NSURL?
    public let thumbURLMedium: NSURL?
    public let thumbURLLarge: NSURL?
    public let rank: Int?
    public let viaUser: String?
    public let viaQuery: String?
    public let postedBy: String
    public let postedById: Int
    public let postedCount: Int
    public let postedByDescription: String
    public let datePosted: NSDate
    public let audioUnavailable: Bool
    public let postURL: NSURL
    public let iTunesURL: NSURL

    public var loved: Bool
    
    override public var description: String {
        return "<Track - artist: \(artist), title: \(title)>"
    }
    
    public required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        guard
            let id = representation["itemid"] as? String,
            let artist = representation["artist"] as? String,
            let title = representation["title"] as? String,
            let lovedCount = representation["loved_count"] as? Int,
            let postedBy = representation["sitename"] as? String,
            let postedById = representation["siteid"] as? Int,
            let postedCount = representation["posted_count"] as? Int,
            let datePostedInterval = representation["dateposted"] as? NSTimeInterval,
            let postURLString = representation["posturl"] as? String,
            let postURLStringEscaped = postURLString.stringByAddingPercentEncodingForURLQueryValue(),
            let postURL = NSURL(string: postURLStringEscaped),
            let iTunesURLString = representation["itunes_link"] as? String,
            let iTunesURLStringEscaped = iTunesURLString.stringByAddingPercentEncodingForURLQueryValue(),
            let iTunesURL = NSURL(string: iTunesURLStringEscaped)
        else {
            // Shouldn't need this, probably a bug, delete later
            self.id = ""
            self.artist = ""
            self.title = ""
            self.loved = false
            self.lovedCount = 0
            self.lovedCountNum = NSNumber()
            self.thumbURLSmall = nil
            self.thumbURLMedium = nil
            self.thumbURLLarge = nil
            self.rank = 0
            self.viaUser = ""
            self.viaQuery = ""
            self.postedBy = ""
            self.postedById = 0
            self.postedCount = 0
            self.postedByDescription = ""
            self.datePosted = NSDate()
            self.audioUnavailable = false
            self.postURL = NSURL()
            self.iTunesURL = NSURL()
            super.init()
            // Shouldn't need this, probably a bug, delete later
            return nil
        }
        
        func urlForJSONKey(key: String) -> NSURL? {
            guard let urlString = representation[key] as? String else {
                return nil
            }
            return NSURL(string: urlString)
        }
        
        self.id = id
        self.artist = artist == "" ? "Unknown artist" : artist
        self.title = title == "" ? "Unknown track" : title
        self.loved = representation["ts_loved_me"] is Int
        self.lovedCount = lovedCount
        self.lovedCountNum = NSNumber(integer: lovedCount)
        self.thumbURLSmall = urlForJSONKey("thumb_url")
        self.thumbURLMedium = urlForJSONKey("thumb_url_medium")
        self.thumbURLLarge = urlForJSONKey("thumb_url_large")
        self.rank = representation["rank"] as? Int
        self.viaUser = representation["via_user"] as? String
        self.viaQuery = representation["via_query"] as? String
        self.postedBy = postedBy
        self.postedById = postedById
        self.postedCount = postedCount
        self.postedByDescription = (representation["description"] as? String) ?? "No description available"
        self.datePosted = NSDate(timeIntervalSince1970: datePostedInterval)
        self.audioUnavailable = representation["pub_audio_unavail"] as? Bool == true
        self.postURL = postURL
        self.iTunesURL = iTunesURL
        
        super.init()
    }
    
    public class func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Track] {
        var tracks = [Track]()
        
        if let collectionJSON = representation as? [NSDictionary] {
            for recordJSON in collectionJSON {
                if let track = Track(response: response, representation: recordJSON) {
                    tracks.append(track)
                }
            }
        }
        
        return tracks
    }
    
    public func mediaURL() -> NSURL {
        var mediaLinkString = "https://hypem.com/serve/public/\(id)"
        if apiKey != nil {
            mediaLinkString += "?key=\(apiKey!)"
        }
        return NSURL(string: mediaLinkString)!
    }
    
    public func thumbURLWithPreferedSize(size: Track.ImageSize) -> NSURL {
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
    
    public func hypeMachineURL() -> NSURL {
        return NSURL(string: "http://hypem.com/track/\(id)")!
    }
    
    public enum ImageSize {
        case Small
        case Medium
        case Large
    }
}
