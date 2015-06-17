//
//  CurrentlyPlaylingTrackViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/13/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class CurrentlyPlaylingTrackViewController: NSViewController {
    @IBOutlet var playPauseButton: HoverToggleButton!
    @IBOutlet var loveButton: TransparentButton!
    @IBOutlet var artistTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var loveContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet var infoContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet var progressSlider: NSSlider!
    @IBOutlet var titleButton: HyperlinkButton!
    @IBOutlet var artistButton: HyperlinkButton!
    
    var dataSource: TracksDataSource!
    var trackInfoWindowController: NSWindowController?
    
    var track: HypeMachineAPI.Track? {
        didSet {
            trackChanged()
        }
    }
    var mouseInside: Bool = false {
        didSet{ mouseInsideChanged() }
    }
    var playState: PlayState = PlayState.NotPlaying {
        didSet { playStateChanged() }
    }
    var trackingProgress: Bool = false
    var trackValue: HypeMachineAPI.Track {
        return track!
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    func initialSetup() {
        Notifications.subscribe(observer: self, selector: "trackPlaying:", name: Notifications.TrackPlaying, object: nil)
        Notifications.subscribe(observer: self, selector: "trackPaused:", name: Notifications.TrackPaused, object: nil)
        Notifications.subscribe(observer: self, selector: "trackLoved:", name: Notifications.TrackLoved, object: nil)
        Notifications.subscribe(observer: self, selector: "trackUnLoved:", name: Notifications.TrackUnLoved, object: nil)
    }
    
    func trackChanged() {
        playState = currentPlayState()
        updateTrackAvailability()
        updateTrackTitle()
        updateTrackArtist()
        mouseInside = false
        loveButton.selected = trackValue.loved
        progressSlider.doubleValue = 0
    }
    
    func currentPlayState() -> PlayState {
        if AudioPlayer.sharedInstance.currentTrack === trackValue {
            if AudioPlayer.sharedInstance.playing {
                return PlayState.Playing
            } else {
                return PlayState.Paused
            }
        } else {
            return PlayState.NotPlaying
        }
    }
    
    func mouseInsideChanged() {
        updatePlayPauseButtonVisibility()
        updateTextFieldsSpacing()
        updateLoveContainerSpacing()
        updateInfoContainerSpacing()
    }
    
    func playStateChanged() {
        updatePlayPauseButtonVisibility()
        updatePlayPauseButtonSelected()
        updateProgressSliderVisibility()
        trackOrUntrackProgress()
        updateTrackTitle()
        updateTrackArtist()
    }
    
    func updateTrackAvailability() {
        if trackValue.audioUnavailable {
            // TODO:
        } else {
            
        }
    }
    
    func updateTrackTitle() {
        titleButton.title = trackValue.title
        switch playState {
        case .Playing, .Paused:
            titleButton.selected = true
        case .NotPlaying:
            titleButton.selected = false
        }
    }
    
    func updateTrackArtist() {
        artistButton.title = trackValue.artist
        switch playState {
        case .Playing, .Paused:
            artistButton.selected = true
        case .NotPlaying:
            artistButton.selected = false
        }
    }
    
    func updatePlayPauseButtonVisibility() {
        if mouseInside {
            playPauseButton.hidden = false
        } else {
            switch playState {
            case .Playing, .Paused:
                playPauseButton.hidden = false
            case .NotPlaying:
                playPauseButton.hidden = true
            }
        }
    }
    
    func updatePlayPauseButtonSelected() {
        switch playState {
        case .Playing:
            playPauseButton.selected = true
        case .Paused, .NotPlaying:
            playPauseButton.selected = false
        }
    }
    
    func updateProgressSliderVisibility() {
        switch playState {
        case .Playing, .Paused:
            progressSlider.hidden = false
        case .NotPlaying:
            progressSlider.hidden = true
        }
    }
    
    func trackOrUntrackProgress() {
        switch playState {
        case .Playing, .Paused:
            trackProgress()
        case .NotPlaying:
            untrackProgress()
        }
    }
    
    func updateTextFieldsSpacing() {
        var mouseOutSpacing: CGFloat = 32
        var mouseInSpacing: CGFloat = 20
        
        if mouseInside {
            artistTrailingConstraint.constant = mouseInSpacing
            titleTrailingConstraint.constant = mouseInSpacing
        } else {
            artistTrailingConstraint.constant = mouseOutSpacing
            titleTrailingConstraint.constant = mouseOutSpacing
        }
    }
    
    func updateLoveContainerSpacing() {
        var openWidth: CGFloat = 38
        var closedWidth: CGFloat = 0
        
        if mouseInside || (trackValue.loved && showLoveButton()) {
            loveContainerWidthConstraint.constant = openWidth
        } else {
            loveContainerWidthConstraint.constant = closedWidth
        }
    }
    
    func updateInfoContainerSpacing() {
        var openWidth: CGFloat = 30
        var closedWidth: CGFloat = 0
        
        if mouseInside {
            infoContainerWidthConstraint.constant = openWidth
        } else {
            infoContainerWidthConstraint.constant = closedWidth
        }
    }
    
    func showLoveButton() -> Bool {
        if dataSource is FavoriteTracksDataSource {
            return false
        } else {
            return true
        }
    }
    
    func trackProgress() {
        if trackingProgress == false {
            Notifications.subscribe(observer: self, selector: "progressUpdated:", name: Notifications.TrackProgressUpdated, object: nil)
        }
        trackingProgress = true
    }
    
    func untrackProgress() {
        Notifications.unsubscribe(observer: self, name: Notifications.TrackProgressUpdated, object: self)
        trackingProgress = false
    }
    
    func trackPlaying(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if track !== notificationTrack {
            track = notificationTrack
            playState = PlayState.Playing
            view.hidden = true
        }
    }
    
    func trackPaused(notification: NSNotification) {
        playState = PlayState.Paused
    }
    
    func trackLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if track != nil && track! === notificationTrack {
            trackValue.loved = true
            loveButton.selected = true
        }
    }
    
    func trackUnLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if track != nil && track === notificationTrack {
            trackValue.loved = false
            loveButton.selected = false
        }
    }
    
    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
        Analytics.trackButtonClick("Playlist Play/Pause")
        switch playState {
        case .Playing:
            AudioPlayer.sharedInstance.pause()
        case .Paused, .NotPlaying:
            AudioPlayer.sharedInstance.playNewTrack(trackValue, dataSource: dataSource!)
        }
    }
    
    @IBAction func infoButtonClicked(sender: TransparentButton) {
        Analytics.trackButtonClick("Playlist Info")
        if trackInfoWindowController == nil {
            trackInfoWindowController = NSStoryboard(name: "TrackInfo", bundle: nil)!.instantiateInitialController() as? NSWindowController
            var trackInfoViewController = trackInfoWindowController!.window!.contentViewController!
            trackInfoViewController.representedObject = track
        }
        trackInfoWindowController!.showWindow(self)
    }
    
    @IBAction func loveButtonClicked(sender: TransparentButton) {
        Analytics.trackButtonClick("Playlist Heart")
        let oldLovedValue = trackValue.loved
        let newLovedValue = !oldLovedValue
        
        changeTrackLovedValueTo(newLovedValue)
        
        HypeMachineAPI.Requests.Me.toggleTrackFavorite(id: trackValue.id, optionalParams: nil) {
            (favorited, error) in
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                self.changeTrackLovedValueTo(oldLovedValue)
            }
            
            if favorited! != newLovedValue {
                self.changeTrackLovedValueTo(favorited!)
            }
        }
    }
    
    @IBAction func progressSliderDragged(sender: NSSlider) {
        AudioPlayer.sharedInstance.seekToPercent(sender.doubleValue)
    }
    
    @IBAction func artistButtonClicked(sender: NSButton) {
        var viewController = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController
        viewController.title = trackValue.artist
        viewController.defaultAnalyticsViewName = "MainWindow/SingleArtist"
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
        viewController.dataSource = ArtistTracksDataSource(artistName: trackValue.artist)
        viewController.dataSource!.viewController = viewController
    }
    
    @IBAction func titleButtonClicked(sender: NSButton) {
        println("Track title clicked: \(trackValue.title)")
    }
    
    func changeTrackLovedValueTo(loved: Bool) {
        if loved {
            Notifications.post(name: Notifications.TrackLoved, object: self, userInfo: ["track": trackValue])
        } else {
            Notifications.post(name: Notifications.TrackUnLoved, object: self, userInfo: ["track": trackValue])
        }
    }
    
    func progressUpdated(notification: NSNotification) {
        let progress = (notification.userInfo!["progress"] as! NSNumber).doubleValue
        let duration = (notification.userInfo!["duration"] as! NSNumber).doubleValue
        progressSlider.doubleValue = progress / duration
    }
    
    enum PlayState {
        case Playing
        case Paused
        case NotPlaying
    }
}
