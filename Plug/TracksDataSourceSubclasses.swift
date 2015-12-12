//
//  PopularTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire
import HypeMachineAPI

class PopularTracksDataSource: TracksDataSource {
    let mode: PopularSectionMode
    
    init(viewController: DataSourceViewController, mode: PopularSectionMode) {
        self.mode = mode
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override var objectsPerPage: Int {
        return 50
    }
    override var singlePage: Bool {
        return true
    }
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Tracks.popular(optionalParams: mode.params.merge(nextPageParams), callback: nextPageTracksReceived)
    }
}

class FavoriteTracksDataSource: TracksDataSource {
    let playlist: FavoritesSectionPlaylist
    
    init(viewController: DataSourceViewController, playlist: FavoritesSectionPlaylist) {
        self.playlist = playlist
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        switch playlist {
        case .All:
            HypeMachineAPI.Requests.Me.favorites(optionalParams: nextPageParams, callback: nextPageTracksReceived)
        case .One:
            HypeMachineAPI.Requests.Me.showPlaylist(id: 1, optionalParams: nextPageParams, callback: nextPageTracksReceived)
        case .Two:
            HypeMachineAPI.Requests.Me.showPlaylist(id: 2, optionalParams: nextPageParams, callback: nextPageTracksReceived)
        case .Three:
            HypeMachineAPI.Requests.Me.showPlaylist(id: 3, optionalParams: nextPageParams, callback: nextPageTracksReceived)
            
        }
    }
}

class LatestTracksDataSource: TracksDataSource {
    let mode: LatestSectionMode
    
    init(viewController: DataSourceViewController, mode: LatestSectionMode) {
        self.mode = mode
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: mode.params.merge(nextPageParams), callback: nextPageTracksReceived)
    }
}

class FeedTracksDataSource: TracksDataSource {
    let mode: FeedSectionMode
    
    init(viewController: DataSourceViewController, mode: FeedSectionMode) {
        self.mode = mode
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Me.feed(optionalParams: mode.params.merge(nextPageParams), callback: nextPageTracksReceived)
    }
}

class BlogTracksDataSource: TracksDataSource {
    let blogID: Int
    
    init(viewController: DataSourceViewController, blogID: Int) {
        self.blogID = blogID
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Blogs.showTracks(id: blogID, optionalParams: nextPageParams, callback: nextPageTracksReceived)
    }
}

class UserTracksDataSource: TracksDataSource {
    let username: String
    
    init(viewController: DataSourceViewController, username: String) {
        self.username = username
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Users.showFavorites(username: username, optionalParams: nextPageParams, callback: nextPageTracksReceived)
    }
}

class ArtistTracksDataSource: TracksDataSource {
    let artistName: String
    
    init(viewController: DataSourceViewController, artistName: String) {
        self.artistName = artistName
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Artists.showTracks(name: artistName, optionalParams: nextPageParams, callback: nextPageTracksReceived)
    }
}

class TagTracksDataSource: TracksDataSource {
    let tagName: String
    
    init(viewController: DataSourceViewController, tagName: String) {
        self.tagName = tagName
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Tags.showTracks(name: tagName, optionalParams: nextPageParams, callback: nextPageTracksReceived)
    }
}

class SearchTracksDataSource: TracksDataSource {
    let searchQuery: String
    let sort: SearchSectionSort
    
    init(viewController: DataSourceViewController, sort: SearchSectionSort, searchQuery: String) {
        self.searchQuery = searchQuery
        self.sort = sort
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: sort.params.merge(nextPageParams).merge(["q": searchQuery]), callback: nextPageTracksReceived)
    }
}

class SingleTrackDataSource: TracksDataSource {
    let track: HypeMachineAPI.Track
    
    init(viewController: DataSourceViewController, track: HypeMachineAPI.Track) {
        self.track = track
        super.init(viewController: viewController)
    }
    
    // MARK: HypeMachineDataSource
    
    override var singlePage: Bool {
        return true
    }
    
    override func requestNextPageObjects() {
        nextPageTracksReceived(result: Result.Success([track]))
    }
}