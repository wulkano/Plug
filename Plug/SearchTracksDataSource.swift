//
//  SearchTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class SearchTracksDataSource: TracksDataSource {
    var searchQuery: String
    
    init(searchQuery: String) {
        self.searchQuery = searchQuery
        super.init()
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: ["q": searchQuery], callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: nextPageParams.merge(["q": searchQuery]), callback: requestNextPageResponse)
    }
}