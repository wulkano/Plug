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
    var currentPlaylist: Playlist! {
        didSet {
            recentlyPlayedTrackIndexes = []
        }
    }
    var currentTrack: Track!
    var playing: Bool = false
    var volume: Float = 1 {
        didSet {
            volumeChanged()
        }
    }
    var progressObserver: AnyObject?
    var seeking = false
    var recentlyPlayedTrackIndexes: [Int] = []
    
    override init() {
        super.init()
        bind("volume", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
    }
    
    deinit {
        if progressObserver != nil {
            player.removeTimeObserver(progressObserver)
        }
    }
    
    func reset() {
        if progressObserver != nil {
            player.removeTimeObserver(progressObserver)
        }
        player = nil
        playerItem = nil
        currentPlaylist = nil
        currentTrack = nil
        playing = false
        progressObserver = nil
        seeking = false
    }
    
    func play(track: Track) {
        if currentTrack != track {
            setupForNewTrack(track)
            UserNotifications.Deliver.NewTrackPlaying(track)
        }
        play()
    }
    
    func play() {
        player.play()
        playing = true
        Notifications.post(name: Notifications.TrackPlaying, object: self, userInfo: ["track": currentTrack!])
    }
    
    func pause() {
        player.pause()
        playing = false
        Notifications.post(name: Notifications.TrackPaused, object: self, userInfo: ["track": currentTrack!])
    }
    
    func playPauseToggle() {
        if currentTrack == nil { return }
        
        if playing {
            pause()
        } else {
            play()
        }
    }
    
    func skipForward() {
        if currentPlaylist == nil { return }
        
        if let nextTrack = findNextTrack() {
            play(nextTrack)
        }
    }
    
    func skipBackward() {
        if currentPlaylist == nil { return }
        
        let previousTrack = currentPlaylist.trackBefore(currentTrack)
        if previousTrack != nil {
            play(previousTrack!)
        }
    }
    
    func seekToPercent(percent: Double) {
        seeking = true
        let seconds = percent * currentItemDuration()!
        let time = CMTimeMakeWithSeconds(seconds, 1)
        player.seekToTime(time, completionHandler: {success in
            self.seeking = false
            
            if !success {
                // Minor error
                println("Error seeking")
            }
        })
    }
    
    // MARK : Notification listeners
    
    func currentTrackFinishedPlayingNotification(notification: NSNotification) {
        println("currentTrackFinishedPlayingNotification")
        skipForward()
    }
    
    // MARK: Private methods
    
    private func currentItemDuration() -> Double? {
        if playerItem == nil { return nil }

        return Double(CMTimeGetSeconds(playerItem.duration))
    }
    
    private func setupForNewTrack(track: Track) {
        Analytics.sharedInstance.trackAudioPlaybackEvent("Play New Track")
        
        if playerItem != nil {
            unsubscribeFromPlayerItem(playerItem)
        }
        
        playerItem = AVPlayerItem(URL: track.mediaURL())
        
        subscribeToPlayerItem(playerItem)
        
        if player == nil {
            player = AVPlayer(playerItem: playerItem)
            player.volume = volume
            observeProgressUpdates()
        } else {
            player.replaceCurrentItemWithPlayerItem(playerItem)
        }
        
        if currentPlaylist != track.playlist {
            currentPlaylist = track.playlist
        }
        currentTrack = track
        recentlyPlayedTrackIndexes.append(currentPlaylist.indexOfTrack(currentTrack)!)
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
    
    private func progressUpdated(time: CMTime) {
        if seeking { return }
        
        let progress = Double(CMTimeGetSeconds(time))
        let duration = Double(CMTimeGetSeconds(playerItem.duration))
        let userInfo = [
            "progress": progress,
            "duration": duration,
            "track": currentTrack
        ]
        Notifications.post(name: Notifications.TrackProgressUpdated, object: self, userInfo: userInfo)
    }
    
    private func subscribeToPlayerItem(playerItem: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentTrackFinishedPlayingNotification:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    private func unsubscribeFromPlayerItem(playerItem: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    private func findNextTrack() -> Track? {
        let shuffle = NSUserDefaults.standardUserDefaults().valueForKey("shuffle") as! Bool
        
        if shuffle {
            return nextShuffleTrack()
        } else {
            return currentPlaylist.trackAfter(currentTrack)
        }
    }
    
    private func nextShuffleTrack() -> Track? {
        if recentlyPlayedTrackIndexes.count >= currentPlaylist.tracks.count {
            recentlyPlayedTrackIndexes = []
        }
        
        var nextShuffleTrackIndex = Rand.inRange(0..<currentPlaylist.tracks.count)
        
        while find(recentlyPlayedTrackIndexes, nextShuffleTrackIndex) != nil {
            nextShuffleTrackIndex = Rand.inRange(0..<currentPlaylist.tracks.count)
        }
        
        return currentPlaylist.trackAtIndex(nextShuffleTrackIndex)
    }
}