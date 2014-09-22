//
//  SingleTrackDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 9/13/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SingleTrackDataSource: BasePlaylistDataSource {
    var track: Track

    init(track: Track, viewController: BasePlaylistViewController) {
        self.track = track
        
        super.init(viewController: viewController)
    }
    
    override func requestInitialValues() {
        let playlist = Playlist(tracks: [track], type: .Latest)
        allTracksLoaded = true
        requestInitialValuesSuccess(playlist)
    }
}
