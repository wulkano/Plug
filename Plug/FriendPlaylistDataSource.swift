//
//  SingleFriendPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 9/6/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendPlaylistDataSource: BasePlaylistDataSource {
    var friend: Friend
    
    init(friend: Friend, viewController: BasePlaylistViewController) {
        self.friend = friend
        
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        HypeMachineAPI.Playlists.FriendPlaylist(friend,
            success: requestInitialValuesSuccess,
            failure: requestInitialValuesFailure)
    }
    
    override func requestNextPage() {
        HypeMachineAPI.Tracks.FriendTracks(friend,
            page: currentPage + 1,
            count: 20,
            success: requestNextPageSuccess,
            failure: requestNextPageFailure)
    }
}
