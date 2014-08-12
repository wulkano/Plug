//
//  PopularPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PopularPlaylistDataSource: NSObject, NSTableViewDataSource {
    var playlist: PopularPlaylist?
    var tableView: NSTableView
    var playlistSubType: PopularPlaylistSubType
    var currentPage: Int = 1
    
    init(playlistSubType: PopularPlaylistSubType, tableView: NSTableView) {
        self.tableView = tableView
        self.playlistSubType = playlistSubType
        super.init()
        
        loadInitialValues()
    }
    
    func loadInitialValues() {
        HypeMachineAPI.Playlists.Popular(playlistSubType,
            success: {playlist in
                self.playlist = playlist
                self.tableView.reloadData()
            }, failure: {error in
                AppError.logError(error)
        })
    }
    
    // TODO: find a way to mark the end of a playlist and prevent further calls
    // here
    func loadNextPage() {
        HypeMachineAPI.Tracks.Popular(playlistSubType, page: currentPage + 1, count: 20, success: {tracks in
                self.playlist!.tracks += tracks
                self.tableView.reloadData()
                self.currentPage++
            }, failure: {error in
                AppError.logError(error)
            })
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        if playlist == nil { return nil }
//        if playlist!.tracks.count <= row { return nil }
        
        return playlist!.tracks[row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if playlist == nil { return 0 }
        
        return playlist!.tracks.count
    }
}
