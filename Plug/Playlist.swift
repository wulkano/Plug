//
//  Playlist.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Playlist: NSObject {
    var tracks: [Track]
    var type: PlaylistType
    
    init(tracks: [Track], type: PlaylistType) {
        self.tracks = tracks
        self.type = type
        super.init()
        linkTracksToPlaylist()
    }
    
    func trackAfter(track: Track) -> Track? {
        let currentIndex = indexOfTrack(track)
        let index = currentIndex + 1
        return trackAtIndex(index)
    }
    
    func trackBefore(track: Track) -> Track? {
        let currentIndex = indexOfTrack(track)
        let index = currentIndex - 1
        return trackAtIndex(index)
    }
    
    // MARK: Private methods
    
    private func linkTracksToPlaylist() {
        for track in tracks {
            track.playlist = self
        }
    }
    
    private func indexOfTrack(track: Track) -> Int {
        return tracks.bridgeToObjectiveC().indexOfObject(track)
    }
    
    private func trackAtIndex(index: Int) -> Track? {
        if index >= 0 && index <= tracks.count - 1 {
            return tracks[index]
        } else {
            return nil
        }
    }
}

enum PlaylistType {
    case Popular
    case Favorites
    case Latest
    case Feed
    case Search
}
