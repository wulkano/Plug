//
//  Blog.swift
//  Plug
//
//  Created by Alex Marchant on 6/8/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class Blog : NSObject {
    var siteID : Int
    var siteName : String
    var siteURL : NSURL
    var followers : Int
    var regionName : String
    var totalTracks : Int
    var lastPosted : Int
    var firstPosted : Int
    var blogImageURL : NSURL?
    var blogImageSmallURL : NSURL?
    
    init(JSON json: NSDictionary) {
        siteID = DictHelper.integerValueOrPlaceholder(json["siteid"], placeholder: 0)
        siteName = DictHelper.stringValueOrPlaceholder(json["sitename"], placeholder: "N/A")
        siteURL = DictHelper.urlValueOrPlaceholder(json["siteurl"], placeholder: "http://hypem.com/not-found")
        followers = DictHelper.integerValueOrPlaceholder(json["followers"], placeholder: 0)
        regionName = DictHelper.stringValueOrPlaceholder(json["region_name"], placeholder: "N/A")
        totalTracks = DictHelper.integerValueOrPlaceholder(json["total_tracks"], placeholder: 0)
        lastPosted = DictHelper.integerValueOrPlaceholder(json["last_posted"], placeholder: 0)
        firstPosted = DictHelper.integerValueOrPlaceholder(json["first_posted"], placeholder: 0)
        blogImageURL = DictHelper.urlValueOrNil(json["blog_image"])
        blogImageSmallURL = DictHelper.urlValueOrNil(json["blog_image_small"])
        
        super.init()
    }
    
    func description() -> String {
        return "Blog: \(siteName)"
    }
}