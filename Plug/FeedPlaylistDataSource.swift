//
//  FeedPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FeedPlaylistDataSource: NSObject, PlaylistDataSource {
    var tableView: NSTableView?
    var playlist: FeedPlaylist?
    var playlistSubType: FeedPlaylistSubType
    var currentPage: Int = 1
    
    init(playlistSubType: FeedPlaylistSubType) {
        self.playlistSubType = playlistSubType
        super.init()
    }
    
    func loadInitialValues() {
        HypeMachineAPI.Playlists.Feed(playlistSubType,
            success: {playlist in
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
        HypeMachineAPI.Tracks.Feed(playlistSubType, page: currentPage + 1, count: 20,
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