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
    
    var player: AVPlayer?
    var currentTrack: Track?
    var playing: Bool = false
    
    func playTrack(track: Track) {
        if currentTrack != track {
            player = AVPlayer(URL: track.mediaURL())
            currentTrack = track
        }
        play()
    }
    
    func play() {
        player!.play()
        playing = true
        sendTrackPlayingNotification()
    }
    
    func pause() {
        player!.pause()
        playing = false
        sendTrackPausedNotification()
    }
    
    private func sendTrackPlayingNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackPlaying, object: self, userInfo: ["track": currentTrack!])
    }
    
    private func sendTrackPausedNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(Notifications.TrackPaused, object: self, userInfo: ["track": currentTrack!])
    }
}
