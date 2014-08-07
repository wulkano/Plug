//
//  AudioPlayer.swift
//  Plug
//
//  Created by Alex Marchant on 7/23/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreMedia

class AudioPlayer: NSObject {
    class var sharedInstance: AudioPlayer {
        struct Singleton {
            static let instance = AudioPlayer()
        }
        return Singleton.instance
    }
    
    var player: AVPlayer!
    var currentPlaylist: Playlist!
    var currentTrack: Track!
    var currentTrackIndex: Int = 0
    var playing: Bool = false
    var volume: Float = 1 {
    didSet {
        volumeChanged()
    }
    }
    
    override init() {
        super.init()
        bind("volume", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
    }
    
    func play(track: Track) {
        if currentTrack != track {
            player = AVPlayer(URL: track.mediaURL())
            player.volume = volume
            currentPlaylist = track.playlist
            currentTrack = track
        }
        play()
    }
    
    func play() {
        player.play()
        playing = true
        sendTrackPlayingNotification()
    }
    
    func pause() {
        player.pause()
        playing = false
        sendTrackPausedNotification()
    }
    
    func skipForward() {
        let nextTrack = currentPlaylist.trackAfter(currentTrack)
        if nextTrack != nil {
            play(nextTrack!)
        }
    }
    
    func skipBackward() {
        let previousTrack = currentPlaylist.trackBefore(currentTrack)
        if previousTrack != nil {
            play(previousTrack!)
        }
    }
    
    // MARK: Private methods
    
    private func sendTrackPlayingNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackPlaying, object: self, userInfo: ["track": currentTrack!])
    }
    
    private func sendTrackPausedNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackPaused, object: self, userInfo: ["track": currentTrack!])
    }
    
    private func volumeChanged() {
        if (player != nil) {
            player.volume = volume
        }
    }
}