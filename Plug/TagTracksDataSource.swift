//
//  TagTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

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
        HypeMachineAPI.Requests.Tags.showTracks(name: tagName, optionalParams: ["page": currentPage, "count": tracksPerPage], callback: requestInitialValuesResponse)
    }
}