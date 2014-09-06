//
//  Blog.swift
//  Plug
//
//  Created by Alex Marchant on 7/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Blog: NSObject {
    var id: String!
    var name: String!
    var url: NSURL!
    var followerCount: Int!
    var followerCountNum: NSNumber!
    var trackCount: Int!
    var trackCountNum: NSNumber!
    var imageURL: NSURL!
    var imageURLSmall: NSURL!
    var featured: Bool = false
    var following: Bool = false
    
    init(JSON json: NSDictionary) {
        super.init()
        
        id = String(json["siteid"] as Int)
        name = json["sitename"] as String
        url = NSURL(string: json["siteurl"] as String)
        followerCount = json["followers"] as Int
        followerCountNum = NSNumber(integer: followerCount)
        trackCount = json["total_tracks"] as Int
        trackCountNum = NSNumber(integer: trackCount)
        imageURL = NSURL(string: json["blog_image"] as String)
        imageURLSmall = NSURL(string: json["blog_image_small"] as String)
        if json["ts_featured"] is Int {
            featured = true
        }
        if json["ts_loved_me"] is Int {
            following = true
        }
    }
    
    func imageURLForSize(size: ImageSize) -> NSURL {
        switch size {
        case .Normal:
            return imageURL
        case .Small:
            return imageURLSmall
        }
    }
    
    enum ImageSize {
        case Normal
        case Small
    }
}
