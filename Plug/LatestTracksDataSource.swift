//
//  LatestTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class LatestTracksDataSource: TracksDataSource {
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Tracks.index(optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}