//
//  BlogTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class BlogTracksDataSource: TracksDataSource {
    var blogID: String
    
    init(blogID: String) {
        self.blogID = blogID
        super.init()
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Blogs.showTracks(id: blogID, optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Blogs.showTracks(id: blogID, optionalParams: ["page": currentPage, "count": tracksPerPage], callback: requestInitialValuesResponse)
    }
}