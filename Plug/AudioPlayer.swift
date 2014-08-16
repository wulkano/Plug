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
            setupForNewTrack(track)
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
    
    // MARK : Notification listeners
    
    func currentTrackFinishedPlaying(notification: NSNotification) {
        println("currentTrackFinishedPlaying")
        skipForward()
    }
    
    // MARK: Private methods
    
    private func setupForNewTrack(track: Track) {
        if playerItem != nil {
            unsubscribeFromPlayerItem(playerItem)
        }
        playerItem = AVPlayerItem(URL: track.mediaURL())
        subscribeToPlayerItem(playerItem)
        ensurePlayerForItem(playerItem)
        currentPlaylist = track.playlist
        currentTrack = track
    }
    
    private func ensurePlayerForItem(playerItem: AVPlayerItem) {
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
            player.volume = volume
            observeProgressUpdates()
        } else {
            player.replaceCurrentItemWithPlayerItem(playerItem)
        }
    }
    
    private func volumeChanged() {
        if player != nil {
            player.volume = volume
        }
    }
    
    private func observeProgressUpdates() {
        let thirdOfSecond = CMTimeMake(1, 3)
        progressObserver = player.addPeriodicTimeObserverForInterval(thirdOfSecond, queue: nil, usingBlock: progressUpdated)
    }
    
    private func progressUpdated(time: CMTime) -> Void {
        let progress = Double(CMTimeGetSeconds(time))
        let duration = Double(CMTimeGetSeconds(playerItem.duration))
        Notifications.Post.TrackProgressUpdated(currentTrack, progress: progress, duration: duration, sender: self)
    }
    
    private func subscribeToPlayerItem(playerItem: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentTrackFinishedPlaying:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    private func unsubscribeFromPlayerItem(playerItem: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
}