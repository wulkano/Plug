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
    
    init(mode: PopularSectionMode) {
        self.mode = mode
        super.init()
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
    
    init(mode: FeedSectionMode) {
        self.mode = mode
        super.init()
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
    
    init(blogID: Int) {
        self.blogID = blogID
        super.init()
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
    
    init(username: String) {
        self.username = username
        super.init()
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
    
    init(artistName: String) {
        self.artistName = artistName
        super.init()
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
    
    init(tagName: String) {
        self.tagName = tagName
        super.init()
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
    
    init(sort: SearchSectionSort, searchQuery: String) {
        self.searchQuery = searchQuery
        self.sort = sort
        super.init()
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: sort.params.merge(["q": searchQuery]), callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: sort.params.merge(nextPageParams).merge(["q": searchQuery]), callback: requestNextPageResponse)
    }
}