//
//  BlogPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogPlaylistDataSource: BasePlaylistDataSource {
    var blog: Blog
    
    init(blog: Blog, viewController: BasePlaylistViewController) {
        self.blog = blog
        
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.BlogPlaylist(blog,
            success: requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.BlogTracks(blog,
            page: currentPage + 1,
            count: 20,
            success: requestNextPageSuccess,
            failure: requestNextPageFailure)
    }
}
