//
//  TracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 5/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import HypeMachineAPI

class TracksDataSource: NSObject, NSTableViewDataSource {
    let tracksPerPage: Int = 20
    
    var tracks: [HypeMachineAPI.Track]?
    var currentPage: Int = 0
    var loadingData: Bool = false
    var allTracksLoaded: Bool = false
    var viewController: DataSourceViewController!
    
    init(viewController: DataSourceViewController) {
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
    
    func requestInitialValuesSuccess(tracks: [HypeMachineAPI.Track]) {
        self.tracks = tracks
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
    
    func requestNextPageSuccess(tracks: [HypeMachineAPI.Track], lastPage: Bool) {
        currentPage++
        allTracksLoaded = lastPage
        
        if tracks.count > 0 {
            let rowIndexes = rowIndexesForNewTracks(tracks)
            self.tracks! = self.tracks! + tracks
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
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let hideUnavailableTracks = NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
        if hideUnavailableTracks {
            return tracks!.filter({ $0.audioUnavailable == false })[row]
        } else {
            return tracks![row]
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tracks == nil { return 0 }
        
        let hideUnavailableTracks = NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
        if hideUnavailableTracks {
            return tracks!.filter({ $0.audioUnavailable == false }).count
        } else {
            return tracks!.count
        }
    }
    
    func trackForRow(row: Int) -> HypeMachineAPI.Track? {
        return tracks!.optionalAtIndex(row)
    }
    
    private func rowIndexesForNewTracks(newTracks: [HypeMachineAPI.Track]) -> NSIndexSet {
        let rowRange: NSRange = NSMakeRange(tracks!.count, newTracks.count)
        return NSIndexSet(indexesInRange: rowRange)
    }
}