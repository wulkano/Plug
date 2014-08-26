//
//  LatestPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LatestPlaylistDataSource: NSObject, PlaylistDataSource, NSTableViewDataSource {
    var tableView: NSTableView?
    var playlist: Playlist?
    var currentPage: Int = 1
    
    func loadInitialValues() {
        HypeMachineAPI.Playlists.Latest(
            {playlist in
                self.playlist = playlist
                self.tableView?.reloadData()
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    // TODO: find a way to mark the end of a playlist and prevent further calls
    // here
    func loadNextPage() {
        HypeMachineAPI.Tracks.Latest(currentPage + 1, count: 20,
            success: {tracks in
                self.playlist!.tracks += tracks
                self.tableView?.reloadData()
                self.currentPage++
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
            })
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        return playlist!.tracks[row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if playlist == nil { return 0 }
        
        return playlist!.tracks.count
    }
    
    func trackForRow(row: Int) -> Track {
        return playlist!.tracks[row]
    }
}
