//
//  PopularTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class PopularTracksDataSource: TracksDataSource {
    var mode: PopularSectionMode
    
    init(viewController: DataSourceViewController, mode: PopularSectionMode) {
        self.mode = mode
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tracks.popular(optionalParams: mode.params, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tracks.popular(optionalParams: mode.params.merge(nextPageParams), callback: requestNextPageResponse)
    }
}

class LatestTracksDataSource: TracksDataSource {
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}

class FeedTracksDataSource: TracksDataSource {
    var mode: FeedSectionMode
    
    init(viewController: DataSourceViewController, mode: FeedSectionMode) {
        self.mode = mode
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Me.feed(optionalParams: mode.params, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Me.feed(optionalParams: mode.params.merge(nextPageParams), callback: requestNextPageResponse)
    }
}

class FavoriteTracksDataSource: TracksDataSource {
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Me.favorites(optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Me.favorites(optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}

class BlogTracksDataSource: TracksDataSource {
    var blogID: Int
    
    init(viewController: DataSourceViewController, blogID: Int) {
        self.blogID = blogID
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Blogs.showTracks(id: blogID, optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Blogs.showTracks(id: blogID, optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}

class UserTracksDataSource: TracksDataSource {
    var username: String
    
    init(viewController: DataSourceViewController, username: String) {
        self.username = username
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Users.showFavorites(username: username, optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Users.showFavorites(username: username, optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}

class ArtistTracksDataSource: TracksDataSource {
    var artistName: String
    
    init(viewController: DataSourceViewController, artistName: String) {
        self.artistName = artistName
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Artists.showTracks(name: artistName, optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Artists.showTracks(name: artistName, optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}

class TagTracksDataSource: TracksDataSource {
    var tagName: String
    
    init(viewController: DataSourceViewController, tagName: String) {
        self.tagName = tagName
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tags.showTracks(name: tagName, optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tags.showTracks(name: tagName, optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}

class SearchTracksDataSource: TracksDataSource {
    var searchQuery: String
    var sort: SearchSectionSort
    
    init(viewController: DataSourceViewController, sort: SearchSectionSort, searchQuery: String) {
        self.searchQuery = searchQuery
        self.sort = sort
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: sort.params.merge(["q": searchQuery]), callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: sort.params.merge(nextPageParams).merge(["q": searchQuery]), callback: requestNextPageResponse)
    }
}

class SingleTrackDataSource: TracksDataSource {
    let track: HypeMachineAPI.Track
    
    init(viewController: DataSourceViewController, track: HypeMachineAPI.Track) {
        self.track = track
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        self.allTracksLoaded = true
        requestInitialValuesResponse([track], error: nil)
    }
}