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
    
    func addTracks(newTracks: [Track]) {
        for track in newTracks {
            track.playlist = self
            tracks.append(track)
        }
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
        return find(tracks, track)!
    }
    
    private func trackAtIndex(index: Int) -> Track? {
        if index >= 0 && index <= tracks.count - 1 {
            return tracks[index]
        } else {
            return nil
        }
    }
    
    class func mockPlaylist(count: Int) -> Playlist {
        var tracks = [Track]()
        for i in 1...count {
            let fakeTrackData = [
                "artist": "Artist",
                "title": "Title",
            ]
            tracks.append(Track(JSON: fakeTrackData))
        }
        return Playlist(tracks: tracks, type: PlaylistType.Popular)
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
