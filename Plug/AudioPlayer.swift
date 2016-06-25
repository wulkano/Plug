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
    var timeoutTimer: NSTimer?
    let timeoutSeconds: Double = 10
    
    override init() {
        super.init()
        bind("volume", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
    }
    
    deinit {
        if progressObserver != nil {
            player.removeTimeObserver(progressObserver!)
        }
    }
    
    func reset() {
        if progressObserver != nil {
            player.removeTimeObserver(progressObserver!)
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
    
    func findAndSetCurrentlyPlayingTrack() {
        if currentDataSource == nil || currentTrack == nil {
            return
        }
        
        let foundTracks: [Track]? = currentDataSource.tableContents?.filter{ ($0 as! HypeMachineAPI.Track).id == currentTrack.id } as? [Track]
        guard let foundTrack = foundTracks?.first else {
            return;
        }
        if currentTrack != foundTrack {
            currentTrack = foundTrack
        }
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
        guard currentTrack != nil else { return }
        
        if playing {
            pause()
        } else {
            play()
        }
    }
    
    func skipForward() {
        guard currentDataSource != nil else { return }
        
        if let nextTrack = findNextTrack() {
            playNewTrack(nextTrack, dataSource: currentDataSource)
        }
    }
    
    func skipBackward() {
        guard currentDataSource != nil else { return }
        
        if let previousTrack = currentDataSource.trackBefore(currentTrack) {
            playNewTrack(previousTrack, dataSource: currentDataSource)
        }
    }
    
    func seekToPercent(percent: Double) {
        guard playerItem != nil && playerItem.status == AVPlayerItemStatus.ReadyToPlay
            else { return }
        
        seeking = true
        let seconds = percent * currentItemDuration()!
        let time = CMTimeMakeWithSeconds(seconds, 1000)
        player.seekToTime(time, completionHandler: {success in
            self.seeking = false
            
            if !success {
                // Minor error
                print("Error seeking")
            }
        })
    }
    
    // MARK : Notification listeners
    
    func currentTrackFinishedPlayingNotification(notification: NSNotification) {
        print("currentTrackFinishedPlayingNotification")
        skipForward()
    }
    
    func currentTrackCouldNotFinishPlayingNotification(notification: NSNotification) {
        let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Streaming error. Skipping to next track."])
        currentTrackPlaybackError(error)
    }
    
    func currentTrackPlaybackStalledNotification(notification: NSNotification) {
        let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Streaming error. Skipping to next track."])
        currentTrackPlaybackError(error)
    }
    
    func currentTrackNewAccessLogEntry(notification: NSNotification) {
//        print((notification.object as! AVPlayerItem).accessLog())
    }
    
    func currentTrackNewErrorLogEntry(notification: NSNotification) {
        print((notification.object as! AVPlayerItem).errorLog())
    }
    
    func currentTrackPlaybackError(error: NSError) {
        Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
        print(error)
        skipForward()
    }
    
    func didAVPlayerTimeout() {
        guard player != nil else { return }
        
        if let val = player.currentItem?.loadedTimeRanges.optionalAtIndex(0) {
            var timeRange: CMTimeRange = CMTimeRange()
            val.getValue(&timeRange)
            let duration = timeRange.duration
            let timeLoaded = Float(duration.value) / Float(duration.timescale)
            
            if timeLoaded == 0 {
                avPlayerTimedOut()
            }
        } else {
            avPlayerTimedOut()
        }
    }
    
    func avPlayerTimedOut() {
        let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error. Track took too long to load, skipping to next track."])
        currentTrackPlaybackError(error)
    }
    
    // MARK: Private methods
    
    private func currentItemDuration() -> Double? {
        guard playerItem != nil else { return nil }

        return Double(CMTimeGetSeconds(playerItem.duration))
    }
    
    private func setupForNewTrack(track: HypeMachineAPI.Track, dataSource: TracksDataSource) {
        Analytics.trackAudioPlaybackEvent("Play New Track")
        
        if playerItem != nil {
            unsubscribeFromPlayerItem(playerItem)
        }
        
        playerItem = AVPlayerItem(URL: track.mediaURL())
        
        subscribeToPlayerItem(playerItem)
        
        if player != nil && progressObserver != nil {
            player.removeTimeObserver(progressObserver!)
        }

        timeoutTimer?.invalidate()
        timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(timeoutSeconds, target: self, selector: #selector(AudioPlayer.didAVPlayerTimeout), userInfo: nil, repeats: false)
        
        player = AVPlayer(playerItem: playerItem)
        player.volume = volume
        observeProgressUpdates()
        
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
        guard !seeking else { return }
        
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
    
    private func playerItemNotificationNamesAndSelectors() -> [String: Selector] {
        return [
            AVPlayerItemDidPlayToEndTimeNotification: #selector(AudioPlayer.currentTrackFinishedPlayingNotification(_:)),
            AVPlayerItemFailedToPlayToEndTimeNotification: #selector(AudioPlayer.currentTrackCouldNotFinishPlayingNotification(_:)),
            AVPlayerItemPlaybackStalledNotification: #selector(AudioPlayer.currentTrackPlaybackStalledNotification(_:)),
            AVPlayerItemNewAccessLogEntryNotification: #selector(AudioPlayer.currentTrackNewAccessLogEntry(_:)),
            AVPlayerItemNewErrorLogEntryNotification: #selector(AudioPlayer.currentTrackNewErrorLogEntry(_:)),
        ]
    }
    
    private func subscribeToPlayerItem(playerItem: AVPlayerItem) {
        for (name, selector) in playerItemNotificationNamesAndSelectors() {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: selector, name: name, object: playerItem)
        }
    }
    
    private func unsubscribeFromPlayerItem(playerItem: AVPlayerItem) {
        for (name, _) in playerItemNotificationNamesAndSelectors() {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: name, object: playerItem)
        }
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
        
        while recentlyPlayedTrackIndexes.indexOf(nextShuffleTrackIndex) != nil {
            nextShuffleTrackIndex = Rand.inRange(0..<currentDataSource.tableContents!.count)
        }
        
        return currentDataSource.trackAtIndex(nextShuffleTrackIndex)
    }
}