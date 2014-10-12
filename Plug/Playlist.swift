//
//  Playlist.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Playlist: NSObject {
    var tracks: [Track] = []
    var type: PlaylistType
    
    init(tracks: [Track], type: PlaylistType) {
        self.type = type
        super.init()
        
        addTracks(tracks)
    }
    
    func addTracks(newTracks: [Track]) {
        for track in newTracks {
            track.playlist = self
            tracks.append(track)
        }
    }
    
    func trackAfter(track: Track) -> Track? {
        if let currentIndex = indexOfTrack(track) {
            let index = currentIndex + 1
            return trackAtIndex(index)
        } else {
            return nil
        }
    }
    
    func trackBefore(track: Track) -> Track? {
        if let currentIndex = indexOfTrack(track) {
            let index = currentIndex - 1
            return trackAtIndex(index)
        } else {
            return nil
        }
    }
    
    func indexOfTrack(track: Track) -> Int? {
        return find(tracks, track)
    }
    
    func trackAtIndex(index: Int) -> Track? {
        if index >= 0 && index <= tracks.count - 1 {
            return tracks[index]
        } else {
            return nil
        }
    }
    
    func availableTracks() -> [Track] {
        return tracks.filter { $0.audioUnavailable == false }
    }
}

enum PlaylistType {
    case Popular
    case Favorites
    case Latest
    case Feed
    case Search
    case Artist
    case Genre
    case Blog
    case Friend
}
