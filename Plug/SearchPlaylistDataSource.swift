//
//  SearchPlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/18/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SearchPlaylistDataSource: NSObject, PlaylistDataSource, NSTableViewDataSource {
    var tableView: NSTableView?
    var playlist: SearchPlaylist?
    var playlistSubType: SearchPlaylistSubType
    var currentPage: Int = 1
    var searchKeywords: String
    
    init(searchKeywords: String, playlistSubType: SearchPlaylistSubType) {
        self.searchKeywords = searchKeywords
        self.playlistSubType = playlistSubType
        super.init()
    }
    
    func loadInitialValues() {
        HypeMachineAPI.Playlists.Search(searchKeywords, subType: playlistSubType,
            success: {playlist in
                self.playlist = playlist
                self.tableView!.reloadData()
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    // TODO: find a way to mark the end of a playlist and prevent further calls
    // here
    func loadNextPage() {
        HypeMachineAPI.Tracks.Search(searchKeywords, subType: playlistSubType, page: currentPage + 1, count: 20,
            success: {tracks in
                self.playlist!.tracks += tracks
                self.tableView!.reloadData()
                self.currentPage++
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
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
    
    func trackForRow(row: Int) -> Track {
        return playlist!.tracks[row]
    }
}
