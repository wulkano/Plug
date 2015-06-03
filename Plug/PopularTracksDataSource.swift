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
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tracks.popular(nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tracks.popular(["page": currentPage, "count": tracksPerPage], callback: requestInitialValuesResponse)
    }
}