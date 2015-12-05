//
//  Blog.swift
//  Plug
//
//  Created by Alex Marchant on 7/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

public final class Blog: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable {
    public let id: Int
    public let name: String
    public let url: NSURL
    public let followerCount: Int
    public let followerCountNum: NSNumber
    public let trackCount: Int
    public let trackCountNum: NSNumber
    public let imageURL: NSURL
    public let imageURLSmall: NSURL
    public let featured: Bool
    public let following: Bool
    
    override public var description: String {
        return "<Blog - name: \(name)>"
    }
    
    public required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        guard
            let id = representation["siteid"] as? Int,
            let name = representation["sitename"] as? String,
            let urlString = representation["siteurl"] as? String,
            let url = NSURL(string: urlString.stringByReplacingOccurrencesOfString(" ", withString: "")),
            let followerCount = representation["followers"] as? Int,
            let trackCount = representation["total_tracks"] as? Int,
            let imageURLString = representation["blog_image"] as? String,
            let imageURL = NSURL(string: imageURLString),
            let imageURLSmallString = representation["blog_image_small"] as? String,
            let imageURLSmall = NSURL(string: imageURLSmallString)
        else {
            // Shouldn't need this, probably a bug, delete later
            self.id = 0
            self.name = ""
            self.url = NSURL()
            self.followerCount = 0
            self.followerCountNum = NSNumber()
            self.trackCount = 0
            self.trackCountNum = NSNumber()
            self.imageURL = NSURL()
            self.imageURLSmall = NSURL()
            self.featured = false
            self.following = false
            super.init()
            // Shouldn't need this, probably a bug, delete later
            return nil
        }
        
        self.id = id
        self.name = name
        self.url = url
        self.followerCount = followerCount
        self.followerCountNum = NSNumber(integer: followerCount)
        self.trackCount = trackCount
        self.trackCountNum = NSNumber(integer: trackCount)
        self.imageURL = imageURL
        self.imageURLSmall = imageURLSmall
        self.featured = representation["ts_featured"] != nil
        self.following = representation["ts_loved_me"] != nil
        
        super.init()
    }
    
    public class func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Blog] {
        var blogs = [Blog]()
        
        if let collectionJSON = representation as? [NSDictionary] {
            for recordJSON in collectionJSON {
                if let blog = Blog(response: response, representation: recordJSON) {
                    blogs.append(blog)
                }
            }
        }
        
        return blogs
    }
    
    public func imageURLForSize(size: ImageSize) -> NSURL {
        switch size {
        case .Normal:
            return imageURL
        case .Small:
            return imageURLSmall
        }
    }
    
    public enum ImageSize {
        case Normal
        case Small
    }
}
