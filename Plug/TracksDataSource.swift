//
//  TracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 7/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class TracksDataSource: HypeMachineDataSource {
    
    func nextPageTracksReceived(tracks: [HypeMachineAPI.Track]?, error: NSError?) {
        nextPageObjectsReceived(tracks, error: error)
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
        if tableContents == nil { return nil }
        
        let tracks = tableContents as! [HypeMachineAPI.Track]
        return find(tracks, track)
    }
    
    func trackAtIndex(index: Int) -> HypeMachineAPI.Track? {
        if tableContents == nil { return nil }
        
        if index >= 0 && index <= tableContents!.count - 1 {
            return tableContents![index] as? HypeMachineAPI.Track
        } else {
            return nil
        }
    }
    
    // MARK: PlugDataSource
    
    override func filterTableContents(contents: [AnyObject]) -> [AnyObject] {
        let tracks = contents as! [HypeMachineAPI.Track]
        return tracks.filter({ $0.audioUnavailable == false })
    }
}