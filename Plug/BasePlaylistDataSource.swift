//
//  BasePlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/30/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BasePlaylistDataSource: NSObject, NSTableViewDataSource {
    var tableView: NSTableView
    var playlist: Playlist?
    var currentPage: Int = 1
    var loadingData: Bool = false
    var allTracksLoaded: Bool = false
    
    init(tableView: NSTableView) {
        self.tableView = tableView
        super.init()
    }
    
    func loadInitialValues() {
        if loadingData { return }
        
        loadingData = true
        requestInitialValues()
    }
    
    func requestInitialValues() {}
    
    func requestInitialValuesSuccess(newPlaylist: Playlist) {
        playlist = newPlaylist
        tableView.reloadData()
        loadingData = false
    }
    
    func requestInitialValuesFailure(error: NSError) {
        loadingError(error)
    }
    
    // TODO: find a way to mark the end of a playlist and prevent further calls
    // here
    func loadNextPage() {
        if loadingData { return }
        if allTracksLoaded { return }
        
        loadingData = true
        requestNextPage()
    }
    
    func requestNextPage() {}
    
    func requestNextPageSuccess(tracks: [Track]) {
        playlist!.addTracks(tracks)
        tableView.reloadData()
        currentPage++
        loadingData = false
    }
    
    func requestNextPageFailure(error: NSError) {
        loadingError(error)
    }
    
    func loadingError(error: NSError) {
        Notifications.Post.DisplayError(error, sender: self)
        Logger.LogError(error)
        loadingData = false
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
