//
//  TracksDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 7/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa
import Alamofire
import HypeMachineAPI

class TracksDataSource: HypeMachineDataSource {
    
    let infiniteLoadTrackCountFromEnd: Int = 7
    
    func nextPageTracksReceived(response: DataResponse<[HypeMachineAPI.Track]>) {
        nextPageResponseReceived(response)
        AudioPlayer.sharedInstance.findAndSetCurrentlyPlayingTrack()
    }
    
    func trackAfter(_ track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
        if let currentIndex = indexOfTrack(track) {
            if currentIndex+1 >= max(0, tableContents!.count-infiniteLoadTrackCountFromEnd) {
                loadNextPageObjects()
            }
            
            let track = trackAtIndex(currentIndex + 1)
            if track != nil && track!.audioUnavailable {
                return trackAfter(track!)
            }
            return track
        } else {
            return nil
        }
    }
    
    func trackBefore(_ track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
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
    
    func indexOfTrack(_ track: HypeMachineAPI.Track) -> Int? {
        if tableContents == nil { return nil }
        
        let tracks = tableContents as! [HypeMachineAPI.Track]
        return tracks.index(of: track)
    }
    
    func trackAtIndex(_ index: Int) -> HypeMachineAPI.Track? {
        if tableContents == nil { return nil }
        
        if index >= 0 && index <= tableContents!.count - 1 {
            return tableContents![index] as? HypeMachineAPI.Track
        } else {
            return nil
        }
    }
    
    // MARK: HypeMachineDataSource
    
    override func filterTableContents(_ contents: [Any]) -> [Any] {
        let tracks = contents as! [HypeMachineAPI.Track]
        return tracks.filter({ $0.audioUnavailable == false })
    }
}
