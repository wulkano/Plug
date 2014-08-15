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
    var playerItem: AVPlayerItem!
    var currentPlaylist: Playlist!
    var currentTrack: Track!
    var currentTrackIndex: Int = 0
    var playing: Bool = false
    var volume: Float = 1 {
    didSet {
        volumeChanged()
    }
    }
    var progressObserver: AnyObject?
    var count = 0
    
    override init() {
        super.init()
        bind("volume", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
    }
    
    deinit {
        if progressObserver != nil {
            player.removeTimeObserver(progressObserver)
        }
    }
    
    func play(track: Track) {
        if currentTrack != track {
            playerItem = AVPlayerItem(URL: track.mediaURL())
            if player == nil {
                player = AVPlayer(playerItem: playerItem)
                player.volume = volume
                observeProgressUpdates()
            } else {
                player.replaceCurrentItemWithPlayerItem(playerItem)
            }
            currentPlaylist = track.playlist
            currentTrack = track
        }
        play()
    }
    
    func play() {
        player.play()
        playing = true
        Notifications.Post.TrackPlaying(currentTrack!, sender: self)
    }
    
    func pause() {
        player.pause()
        playing = false
        Notifications.Post.TrackPaused(currentTrack!, sender: self)
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
    
    private func volumeChanged() {
        if player != nil {
            player.volume = volume
        }
    }
    
    private func observeProgressUpdates() {
        println(count++)
        let thirdOfSecond = CMTimeMake(1, 3)
        progressObserver = player.addPeriodicTimeObserverForInterval(thirdOfSecond, queue: nil, usingBlock: progressUpdated)
    }
    
    private func progressUpdated(time: CMTime) -> Void {
        let progress = Double(CMTimeGetSeconds(time))
        let duration = Double(CMTimeGetSeconds(playerItem.duration))
        Notifications.Post.TrackProgressUpdated(currentTrack, progress: progress, duration: duration, sender: self)
    }
}