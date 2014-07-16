//
//  HypeMachineAPI.swift
//  Plug
//
//  Created by Alex Marchant on 7/5/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

var apiBase = "https://api.hypem.com/v2"

struct HypeMachineAPI  {
    static func GET(url: String, parameters: Dictionary<String, String>?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func hmToken() -> String {
//        TODO fix this
//        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
//        return SSKeychain.passwordForService("Plug", account: username!)
        return "d7ee8670b0d5d73f29f0733bdf065819"
    }
    
    struct Tracks {
        static func Popular(subType: PopularPlaylistSubType, page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/popular"
            let params = ["mode": subType.toRaw(), "page": "\(page)", "count": "\(count)", "hm_token": HypeMachineAPI.hmToken()]
            
            HypeMachineAPI.GET(url, parameters: params, success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let responseArray = responseObject as NSArray
                var tracks = [Track]()
                for trackObject: AnyObject in responseArray {
                    let trackDictionary = trackObject as NSDictionary
                    tracks.append(Track(JSON: trackDictionary))
                }
                success(tracks: tracks)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                failure(error: error)
            })
        }
        
        static func Favorites(page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/me/favorites"
            let params = ["page": "\(page)", "count": "\(count)", "hm_token": HypeMachineAPI.hmToken()]
            
            HypeMachineAPI.GET(url, parameters: params, success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let responseArray = responseObject as NSArray
                var tracks = [Track]()
                for trackObject: AnyObject in responseArray {
                    let trackDictionary = trackObject as NSDictionary
                    tracks.append(Track(JSON: trackDictionary))
                }
                success(tracks: tracks)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                failure(error: error)
            })
        }
        
        static func Latest(page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tracks"
            let params = ["sort": "latest", "page": "\(page)", "count": "\(count)", "hm_token": HypeMachineAPI.hmToken()]
            
            HypeMachineAPI.GET(url, parameters: params, success: {
                (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                let responseArray = responseObject as NSArray
                var tracks = [Track]()
                for trackObject: AnyObject in responseArray {
                    let trackDictionary = trackObject as NSDictionary
                    tracks.append(Track(JSON: trackDictionary))
                }
                success(tracks: tracks)
            }, failure: {
                (operation: AFHTTPRequestOperation!, error: NSError!) in
                failure(error: error)
            })
        }
    }
    
    struct Playlists {
        static func Popular(subType: PopularPlaylistSubType, success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Popular(subType, page: 1, count: 20, success: {tracks in
                let playlist = PopularPlaylist(tracks: tracks, subType: subType)
                success(playlist: playlist)
            }, failure: failure)
        }
        
        static func Favorites(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Favorites(1, count: 20, success: {tracks in
                let playlist = FavoritesPlaylist(tracks: tracks)
                success(playlist: playlist)
            }, failure: failure)
        }
        
        static func Latest(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Latest(1, count: 20, success: {tracks in
                let playlist = LatestPlaylist(tracks: tracks)
                success(playlist: playlist)
            }, failure: failure)
        }
    }
}