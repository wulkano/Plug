//
//  UserTracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

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
        HypeMachineAPI.Requests.Users.showFavorites(username: username, optionalParams: ["page": currentPage, "count": tracksPerPage], callback: requestInitialValuesResponse)
    }
}