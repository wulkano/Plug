//
//  Friend.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Friend: NSObject {
    var username: String
    var fullName: String
    var avatarURL: NSURL?
    var favoritesCount: Int
    var favoritesCountNum: NSNumber
    var followersCount: Int
    var followersCountNum: NSNumber
    var followingCount: Int
    var followingCountNum: NSNumber
    
    init(JSON json: NSDictionary) {
        
        username = json["username"] as! String
        if json["fullname"] is String {
            fullName = json["fullname"] as! String
        } else {
            fullName = username
        }
        if json["userpic"] is String {
            avatarURL = NSURL(string: json["userpic"] as! String)
        }
        
        var favoritesCountDict = json["favorites_count"] as! NSDictionary
        
        if favoritesCountDict["item"] is Int {
            favoritesCount = favoritesCountDict["item"] as! Int
        } else {
            favoritesCount = 0
        }
        favoritesCountNum = NSNumber(integer: favoritesCount)
        
        if favoritesCountDict["followers"] is Int {
            followersCount = favoritesCountDict["followers"] as! Int
        } else {
            followersCount = 0
        }
        followersCountNum = NSNumber(integer: followersCount)

        if favoritesCountDict["user"] is Int {
            followingCount = favoritesCountDict["user"] as! Int
        } else {
            followingCount = 0
        }
        followingCountNum = NSNumber(integer: followingCount)
        
        super.init()
    }
}
