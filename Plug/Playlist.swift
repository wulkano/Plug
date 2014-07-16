//
//  Playlist.swift
//  Plug
//
//  Created by Alex Marchant on 6/8/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class Playlist : NSObject {
    let BaseUri = "https://api.hypem.com"
    var tracks = [Track]()
    var type : HMPlaylistType
    var ocType : String {
    get {
        return type.stringVal()
    }
    set {
        type = HMPlaylistType.fromString(newValue)
    }
    }
    var searchKeywords : String?
    var timestamp : NSDate?
    var currentPage = 1
    var currentTrackIndex = 0
    
    init(tracks: [Track], type: HMPlaylistType) {
        self.type = type
        self.tracks = tracks
        super.init()
    }
    
    init(type: HMPlaylistType) {
        self.type = type
        super.init()
    }
    
    func description() -> String {
        var str = "\n"
        for track in tracks {
            str += track.description + "\n"
        }
        return str
    }
    
    func addTracks(tracks: [Track]) {
        self.tracks += tracks
    }
    
    func getNextPage() {
        var requestURL : NSURL
        var token = HypeMachineAPI.hmToken()
        currentPage += 1
        
        switch type {
        case .PopularNow:
            requestURL = NSURL(string: "/v2/popular?mode=now&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string:BaseUri))
        case .PopularArtists:
            requestURL = NSURL(string: "/v2/artists?sort=popular&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .PopularLastWeek:
            requestURL = NSURL(string: "/v2/popular?mode=lastweek&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .PopularNoRemix:
            requestURL = NSURL(string: "/v2/popular?mode=noremix&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .PopularRemix:
            requestURL = NSURL(string: "/v2/popular?mode=remix&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .LatestNewest:
            requestURL = NSURL(string: "/v2/tracks?sort=latest&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .UserFavorites:
            requestURL = NSURL(string: "/v2/me/favorites?page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .UserFeedAll:
            requestURL = NSURL(string: "/v2/me/feed?page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .UserFeedFriends:
            requestURL = NSURL(string: "/v2/me/feed?mode=friends&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .UserFeedArtists:
            requestURL = NSURL(string: "/v2/me/feed?mode=artists&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .UserFeedBlogs:
            requestURL = NSURL(string: "/v2/me/feed?mode=blogs&page=\(currentPage)&count=20&hm_token=\(token)", relativeToURL:NSURL(string: BaseUri))
        case .SearchLatest:
            let escapedKeywords = searchKeywords!.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
            let searchString = "/v2/tracks?q=\(escapedKeywords)&sort=latest&page=\(currentPage)&count=20&hm_token=\(token)"
            requestURL = NSURL(string: searchString, relativeToURL:NSURL(string: BaseUri))
        case .SearchLoved:
            let escapedKeywords = searchKeywords!.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
            let searchString = "/v2/tracks?q=\(escapedKeywords)&sort=loved&page=\(currentPage)&count=20&hm_token=\(token)"
            requestURL = NSURL(string: searchString, relativeToURL:NSURL(string: BaseUri))
        case .SearchPosted:
            let escapedKeywords = searchKeywords!.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
            let searchString = "/v2/tracks?q=\(escapedKeywords)&sort=posted&page=\(currentPage)&count=20&hm_token=\(token)"
            requestURL = NSURL(string: searchString, relativeToURL:NSURL(string: BaseUri))
        }
        
//        let jsonResponse = HMRequest.synchronousRequestJSONfromUrl(requestURL)
//        addTracks(jsonResponse)
    }
}

enum HMPlaylistType {
    case PopularNow
    case PopularArtists
    case PopularLastWeek
    case PopularNoRemix
    case PopularRemix
    case LatestNewest
    case UserFavorites
    case UserFeedAll
    case UserFeedFriends
    case UserFeedArtists
    case UserFeedBlogs
    case SearchLatest
    case SearchLoved
    case SearchPosted
    
    static func fromString(type: String) -> HMPlaylistType {
        switch type {
        case HMPlaylistPopularNow:
            return HMPlaylistType.PopularNow
        case HMPlaylistPopularArtists:
            return HMPlaylistType.PopularArtists
        case HMPlaylistPopularLastWeek:
            return HMPlaylistType.PopularLastWeek
        case HMPlaylistPopularNoRemix:
            return HMPlaylistType.PopularNoRemix
        case HMPlaylistPopularRemix:
            return HMPlaylistType.PopularRemix
        case HMPlaylistLatestNewest:
            return HMPlaylistType.LatestNewest
        case HMPlaylistUserFavorites:
            return HMPlaylistType.UserFavorites
        case HMPlaylistUserFeedAll:
            return HMPlaylistType.UserFeedAll
        case HMPlaylistUserFeedFriends:
            return HMPlaylistType.UserFeedFriends
        case HMPlaylistUserFeedArtists:
            return HMPlaylistType.UserFeedArtists
        case HMPlaylistUserFeedBlogs:
            return HMPlaylistType.UserFeedBlogs
        case HMPlaylistSearchLatest:
            return HMPlaylistType.SearchLatest
        case HMPlaylistSearchLoved:
            return HMPlaylistType.SearchLoved
        case HMPlaylistSearchPosted:
            return HMPlaylistType.SearchPosted
        default:
            NSLog("Error: Reached end of switch statement in HMPlaylistType.fromString()")
            return HMPlaylistType.PopularNow
        }
    }
    
    func stringVal() -> String {
        var result : String
        switch self {
        case .PopularNow:
            return HMPlaylistPopularNow
        case .PopularArtists:
            return HMPlaylistPopularArtists
        case .PopularLastWeek:
            return HMPlaylistPopularLastWeek
        case .PopularNoRemix:
            return HMPlaylistPopularNoRemix
        case .PopularRemix:
            return HMPlaylistPopularRemix
        case .LatestNewest:
            return HMPlaylistLatestNewest
        case .UserFavorites:
            return HMPlaylistUserFavorites
        case .UserFeedAll:
            return HMPlaylistUserFeedAll
        case .UserFeedFriends:
            return HMPlaylistUserFeedFriends
        case .UserFeedArtists:
            return HMPlaylistUserFeedArtists
        case .UserFeedBlogs:
            return HMPlaylistUserFeedBlogs
        case .SearchLatest:
            return HMPlaylistSearchLatest
        case .SearchLoved:
            return HMPlaylistSearchLoved
        case .SearchPosted:
            return HMPlaylistSearchPosted
        }
    }
}