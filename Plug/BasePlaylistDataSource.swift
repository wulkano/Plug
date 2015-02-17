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
    var viewController: BaseDataSourceViewController
    
    init(viewController: BaseDataSourceViewController) {
        self.viewController = viewController
        super.init()
    }
    
    func loadInitialValues() {
        if loadingData { return }
        
        loadingData = true
        requestInitialValues()
    }
    
    func refresh() {
        loadInitialValues()
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
        Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
        Logger.LogError(error)
        loadingData = false
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        
        let hideUnavailableTracks = NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
        if hideUnavailableTracks {
            return playlist!.availableTracks()[row]
        } else {
            return playlist!.tracks[row]
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if playlist == nil { return 0 }
        
        let hideUnavailableTracks = NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
        if hideUnavailableTracks {
            return playlist!.availableTracks().count
        } else {
            return playlist!.tracks.count
        }
    }
    
    func trackForRow(row: Int) -> Track? {
        return playlist!.tracks.optionalAtIndex(row)
    }
    
    private func rowIndexesForNewTracks(tracks: [Track]) -> NSIndexSet {
        let rowRange: NSRange = NSMakeRange(playlist!.tracks.count, tracks.count)
        return NSIndexSet(indexesInRange: rowRange)
    }
}
