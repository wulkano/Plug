//
//  BasePlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/30/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BasePlaylistDataSource: NSObject, NSTableViewDataSource {
    var playlist: Playlist?
    var currentPage: Int = 1
    var loadingData: Bool = false
    var allTracksLoaded: Bool = false
    var viewController: BasePlaylistViewController
    
    init(viewController: BasePlaylistViewController) {
        self.viewController = viewController
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
        viewController.tableView.reloadData()
        loadingData = false
        viewController.requestInitialValuesFinished()
    }
    
    func requestInitialValuesFailure(error: NSError) {
        loadingError(error)
        viewController.requestInitialValuesFinished()
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
    
    func requestNextPageSuccess(tracks: [Track], lastPage: Bool) {
        currentPage++
        allTracksLoaded = lastPage
        
        if tracks.count > 0 {
            let rowIndexes = rowIndexesForNewTracks(tracks)
            playlist!.addTracks(tracks)
            viewController.tableView.insertRowsAtIndexes(rowIndexes, withAnimation: .EffectNone)
        }
        
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
    
    private func rowIndexesForNewTracks(tracks: [Track]) -> NSIndexSet {
        let rowRange: NSRange = NSMakeRange(playlist!.tracks.count, tracks.count)
        return NSIndexSet(indexesInRange: rowRange)
    }
}
