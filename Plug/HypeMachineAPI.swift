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
//        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
//        return SSKeychain.passwordForService("Plug", account: username!)
        return "d7ee8670b0d5d73f29f0733bdf065819"
    }
    
    struct Tracks {
        static func popular(mode: PopularMode, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            popular(mode, page: 1, count: 20, success: success, failure: failure)
        }
        
        static func popular(mode: PopularMode, page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tracks"
            let params = ["mode": mode.toRaw(), "page": "\(page)", "count": "\(count)", "hm_token": HypeMachineAPI.hmToken()]
            
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
        
        static func latest(mode: LatestMode, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            latest(mode, page: 1, count: 20, success: success, failure: failure)
        }
        
        static func latest(mode: LatestMode, page: Int, count: Int, success: (tracks: [Track])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tracks"
            let params = ["mode": mode.toRaw(), "page": "\(page)", "count": "\(count)", "hm_token": HypeMachineAPI.hmToken()]
            
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
        
        enum PopularMode: String {
            case Now = "now"
            case LastWeek = "lastweek"
            case NoRemix = "noremix"
            case Remix = "remix"
        }
        
        enum LatestMode: String {
            case Now = "now"
            case LastWeek = "lastweek"
            case NoRemix = "noremix"
            case Remix = "remix"
        }
    }
    
    struct Playlists {
        static func popularNow(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.popular(HypeMachineAPI.Tracks.PopularMode.Now, success: {tracks in
                let playlist = Playlist(tracks: tracks, type: HMPlaylistType.PopularNow)
                success(playlist: playlist)
            }, failure: failure)
        }
        
        static func popularLastWeek(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.popular(HypeMachineAPI.Tracks.PopularMode.LastWeek, success: {tracks in
                let playlist = Playlist(tracks: tracks, type: HMPlaylistType.PopularLastWeek)
                success(playlist: playlist)
                }, failure: failure)
        }
        
        static func popularNoRemix(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.popular(HypeMachineAPI.Tracks.PopularMode.NoRemix, success: {tracks in
                let playlist = Playlist(tracks: tracks, type: HMPlaylistType.PopularNoRemix)
                success(playlist: playlist)
                }, failure: failure)
        }
        
        static func popularRemix(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.popular(HypeMachineAPI.Tracks.PopularMode.Remix, success: {tracks in
                let playlist = Playlist(tracks: tracks, type: HMPlaylistType.PopularRemix)
                success(playlist: playlist)
                }, failure: failure)
        }
    }
}