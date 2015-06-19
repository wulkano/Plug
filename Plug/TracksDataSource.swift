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
    
    @IBOutlet var viewController: DataSourceViewController!
    
    var tracks: [HypeMachineAPI.Track]?
    var availableTracks: [HypeMachineAPI.Track]? {
        if tracks == nil { return nil }
        return filterAvailableTracks(tracks!)
    }
    var hideUnavailableTracks: Bool {
        return NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
    }
    var tracksToDisplay: [HypeMachineAPI.Track]? {
        if hideUnavailableTracks {
            return availableTracks
        } else {
            return tracks
        }
    }
    var currentPage: Int = 1
    var loadingData: Bool = false
    var allTracksLoaded: Bool = false
    var nextPageParams: [String: AnyObject] {
        get {
            return [
                "page": currentPage + 1,
                "count": tracksPerPage,
            ]
        }
    }
    
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
    
    func requestInitialValuesResponse(tracks: [HypeMachineAPI.Track]?, error: NSError?) {
        if error != nil {
            loadingError(error!)
            viewController.requestInitialValuesFinished()
            return
        }
        
        self.tracks = tracks
        viewController.tableView.reloadData()
        loadingData = false
        viewController.requestInitialValuesFinished()
    }
    
    func loadNextPage() {
        if loadingData { return }
        if allTracksLoaded { return }
        
        loadingData = true
        requestNextPage()
    }
    
    func requestNextPage() {}
    
    func requestNextPageResponse(newTracks: [HypeMachineAPI.Track]?, error: NSError?) {
        
        if error != nil {
            loadingError(error!)
            return
        }
        
        currentPage++
        allTracksLoaded = newTracks!.count < tracksPerPage
        
        if newTracks!.count > 0 {
            let rowIndexes = rowIndexesForNewTracks(newTracks!)
            self.tracks! = self.tracks! + newTracks!
            viewController.tableView.insertRowsAtIndexes(rowIndexes, withAnimation: .EffectNone)
        }
        
        loadingData = false
    }
    
    func loadingError(error: NSError) {
        Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
        println(error)
        loadingData = false
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return tracksToDisplay![row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tracksToDisplay == nil { return 0 }
        return tracksToDisplay!.count
    }
    
    func trackForRow(row: Int) -> HypeMachineAPI.Track? {
        return tracksToDisplay!.optionalAtIndex(row)
    }
    
    private func rowIndexesForNewTracks(newTracks: [HypeMachineAPI.Track]) -> NSIndexSet {
        let tracksToAdd: [HypeMachineAPI.Track]
        
        if hideUnavailableTracks {
            tracksToAdd = filterAvailableTracks(newTracks)
        } else {
            tracksToAdd = newTracks
        }
        
        let rowRange: NSRange = NSMakeRange(tracksToDisplay!.count, tracksToAdd.count)
        return NSIndexSet(indexesInRange: rowRange)
    }
    
    func trackAfter(track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
        if let currentIndex = indexOfTrack(track) {
            let track = trackAtIndex(currentIndex + 1)
            if track != nil && track!.audioUnavailable {
                return trackAfter(track!)
            }
            return track
        } else {
            return nil
        }
    }
    
    func trackBefore(track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
        if let currentIndex = indexOfTrack(track) {
            let track = trackAtIndex(currentIndex - 1)
            if track != nil && track!.audioUnavailable {
                return trackBefore(track!)
            }
            return track
        } else {
            return nil
        }
    }
    
    func indexOfTrack(track: HypeMachineAPI.Track) -> Int? {
        if tracks == nil { return nil }
        
        return find(tracks!, track)
    }
    
    func trackAtIndex(index: Int) -> HypeMachineAPI.Track? {
        if tracks == nil { return nil }
        
        if index >= 0 && index <= tracks!.count - 1 {
            return tracks![index]
        } else {
            return nil
        }
    }
    
    func filterAvailableTracks(tracks: [HypeMachineAPI.Track]) -> [HypeMachineAPI.Track] {
        return tracks.filter { $0.audioUnavailable == false }
    }
}