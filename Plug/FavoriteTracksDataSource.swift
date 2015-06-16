//
//  FavoriteTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class FavoriteTracksDataSource: TracksDataSource {
    override func requestInitialValues() {
        HypeMachineAPI.Requests.Me.favorites(optionalParams: nil, callback: requestInitialValuesResponse)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Requests.Me.favorites(optionalParams: nextPageParams, callback: requestNextPageResponse)
    }
}