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
import HypeMachineAPI

class AudioPlayer: NSObject {
    class var sharedInstance: AudioPlayer {
        struct Singleton {
            static let instance = AudioPlayer()
        }
        return Singleton.instance
    }
    
    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    var currentDataSource: TracksDataSource! {
        didSet { recentlyPlayedTrackIndexes = [] }
    }
    var currentTrack: HypeMachineAPI.Track! {
        didSet { currentTrackChanged() }
    }
    var currentTrackListenLogged = false
    var currentTrackListenScrobbled = false
    var playing: Bool = false
    var volume: Float = 1 {
        didSet { volumeChanged() }
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
        currentDataSource = nil
        currentTrack = nil
        playing = false
        progressObserver = nil
        seeking = false
    }
    
    func playNewTrack(track: HypeMachineAPI.Track, dataSource: TracksDataSource) {
        if currentTrack != track {
            setupForNewTrack(track, dataSource: dataSource)
            UserNotifications.deliverNotification(title: track.title, informativeText: track.artist)
            Notifications.post(name: Notifications.NewCurrentTrack, object: self, userInfo: ["track": track])
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
        if currentDataSource == nil { return }
        
        if let nextTrack = findNextTrack() {
            playNewTrack(nextTrack, dataSource: currentDataSource)
        }
    }
    
    func skipBackward() {
        if currentDataSource == nil { return }
        
        if let previousTrack = currentDataSource.trackBefore(currentTrack) {
            playNewTrack(previousTrack, dataSource: currentDataSource)
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
    
    private func setupForNewTrack(track: HypeMachineAPI.Track, dataSource: TracksDataSource) {
        Analytics.trackAudioPlaybackEvent("Play New Track")
        
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
        
        if currentDataSource != dataSource {
            currentDataSource = dataSource
        }
        currentTrack = track
        recentlyPlayedTrackIndexes.append(currentDataSource.indexOfTrack(currentTrack)!)
    }
    
    func currentTrackChanged() {
        currentTrackListenLogged = false
        currentTrackListenScrobbled = false
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
        
        if progress > 30 && !currentTrackListenLogged {
            HypeMachineAPI.Requests.Me.postHistory(id: currentTrack.id, position: 30, optionalParams: nil, callback: {error in})
            currentTrackListenLogged = true
        } else if (progress / duration) > (2 / 3) && !currentTrackListenScrobbled {
            HypeMachineAPI.Requests.Me.postHistory(id: currentTrack.id, position: Int(progress), optionalParams: nil, callback: {error in})
            currentTrackListenScrobbled = true
        }
    }
    
    private func subscribeToPlayerItem(playerItem: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentTrackFinishedPlayingNotification:", name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    private func unsubscribeFromPlayerItem(playerItem: AVPlayerItem) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVPlayerItemDidPlayToEndTimeNotification, object: playerItem)
    }
    
    private func findNextTrack() -> HypeMachineAPI.Track? {
        let shuffle = NSUserDefaults.standardUserDefaults().valueForKey("shuffle") as! Bool
        
        if shuffle {
            return nextShuffleTrack()
        } else {
            return currentDataSource.trackAfter(currentTrack)
        }
    }
    
    private func nextShuffleTrack() -> HypeMachineAPI.Track? {
        if recentlyPlayedTrackIndexes.count >= currentDataSource.tableContents!.count {
            recentlyPlayedTrackIndexes = []
        }
        
        var nextShuffleTrackIndex = Rand.inRange(0..<currentDataSource.tableContents!.count)
        
        while find(recentlyPlayedTrackIndexes, nextShuffleTrackIndex) != nil {
            nextShuffleTrackIndex = Rand.inRange(0..<currentDataSource.tableContents!.count)
        }
        
        return currentDataSource.trackAtIndex(nextShuffleTrackIndex)
    }
}