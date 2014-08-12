//
//  PlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistDataSource: NSObject, NSTableViewDataSource {
    let tableView: NSTableView
    var playlist: Playlist
    
    init(playlistType: PlaylistType, tableView: NSTableView) {
        self.tableView = tableView
        self.playlist = Playlist(tracks: [], type: playlistType)
        super.init()
    }
    
    func loadInitialValues() {
        HypeMachineAPI.Playlists.Popular(PopularPlaylistSubType.Now,
            success: {playlist in
                self.playlist = playlist
                self.tableView.reloadData()
            }, failure: {error in
                AppError.logError(error)
        })
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        if playlist.tracks.count > row {
            return playlist.tracks[row]
        } else {
            return nil
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        return playlist.tracks.count
    }
}
