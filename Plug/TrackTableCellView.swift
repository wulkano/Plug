//
//  TrackTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import SnapKit

class TrackTableCellView: IOSStyleTableCellView {
    let titleColor = NSColor(red256: 0, green256: 0, blue256: 0)
    let artistColor = NSColor(red256: 138, green256: 146, blue256: 150)
    let disabledTitleColor = NSColor(red256: 138, green256: 146, blue256: 150)
    let disabledArtistColor = NSColor(red256: 184, green256: 192, blue256: 196)
    
    var playPauseButton: HoverToggleButton!
    var loveButton: TransparentButton!
//    var artistTrailingConstraint: NSLayoutConstraint!
//    var titleTrailingConstraint: NSLayoutConstraint!
    var loveContainerWidthConstraint: Constraint!
    var infoContainerWidthConstraint: Constraint!
    var progressSlider: NSSlider!
    var titleButton: HyperlinkButton!
    var artistButton: HyperlinkButton!
    var infoContainer: NSView!
    
    var showLoveButton: Bool = true
    
    var dataSource: TracksDataSource!
    var trackInfoWindowController: NSWindowController?
    
    override var objectValue: AnyObject! {
        didSet { objectValueChanged() }
    }
    var track: HypeMachineAPI.Track {
        return objectValue as! HypeMachineAPI.Track
    }
    var mouseInside: Bool = false {
        didSet{ mouseInsideChanged() }
    }
    var playState: PlayState = PlayState.NotPlaying {
        didSet { playStateChanged() }
    }
    var trackingProgress: Bool = false
    
    init() {
        super.init(frame: NSZeroRect)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    func setup() {
        Notifications.subscribe(observer: self, selector: "trackPlaying:", name: Notifications.TrackPlaying, object: nil)
        Notifications.subscribe(observer: self, selector: "trackPaused:", name: Notifications.TrackPaused, object: nil)
        Notifications.subscribe(observer: self, selector: "trackLoved:", name: Notifications.TrackLoved, object: nil)
        Notifications.subscribe(observer: self, selector: "trackUnLoved:", name: Notifications.TrackUnLoved, object: nil)
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }

        playState = currentPlayState()
        updateTrackAvailability()
        updateTrackTitle()
        updateTrackArtist()
        mouseInside = false
        loveButton.selected = track.loved
        progressSlider.doubleValue = 0
    }
    
    func currentPlayState() -> PlayState {
        if AudioPlayer.sharedInstance.currentTrack === objectValue {
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
//        updateTextFieldsSpacing()
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
        if track.audioUnavailable {
            titleButton.textColor = disabledTitleColor
            artistButton.textColor = disabledArtistColor
        } else {
            titleButton.textColor = titleColor
            artistButton.textColor = artistColor
        }
    }
    
    func updateTrackTitle() {
        titleButton.title = track.title
        switch playState {
        case .Playing, .Paused:
            titleButton.selected = true
        case .NotPlaying:
            titleButton.selected = false
        }
    }
    
    func updateTrackArtist() {
        artistButton.title = track.artist
        switch playState {
        case .Playing, .Paused:
            artistButton.selected = true
        case .NotPlaying:
            artistButton.selected = false
        }
    }
    
    func updatePlayPauseButtonVisibility() {
        if track.audioUnavailable {
            playPauseButton.hidden = true
        } else if mouseInside {
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
//    
//    func updateTextFieldsSpacing() {
//        var mouseOutSpacing: CGFloat = 32
//        var mouseInSpacing: CGFloat = 20
//        
//        if mouseInside {
//            artistTrailingConstraint.constant = mouseInSpacing
//            titleTrailingConstraint.constant = mouseInSpacing
//        } else {
//            artistTrailingConstraint.constant = mouseOutSpacing
//            titleTrailingConstraint.constant = mouseOutSpacing
//        }
//    }
    
    func updateLoveContainerSpacing() {
        var openWidth: CGFloat = 38
        var closedWidth: CGFloat = 0
        
        if mouseInside || (track.loved && showLoveButton) {
            loveContainerWidthConstraint.updateOffset(openWidth)
//            loveContainerWidthConstraint.constant = openWidth
        } else {
            loveContainerWidthConstraint.updateOffset(closedWidth)
//            loveContainerWidthConstraint.constant = closedWidth
        }
    }
    
    func updateInfoContainerSpacing() {
        var openWidth: CGFloat = 30
        var closedWidth: CGFloat = 0
        
        if mouseInside {
            infoContainerWidthConstraint.updateOffset(openWidth)
//            infoContainerWidthConstraint.constant = openWidth
        } else {
            infoContainerWidthConstraint.updateOffset(closedWidth)
//            infoContainerWidthConstraint.constant = closedWidth
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
        if notificationTrack === objectValue {
            playState = PlayState.Playing
        } else {
            playState = PlayState.NotPlaying
        }
    }
    
    func trackPaused(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if notificationTrack === objectValue {
            playState = PlayState.Paused
        }
    }
    
    func trackLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if notificationTrack === objectValue {
            track.loved = true
            loveButton.selected = true
        }
        updateLoveContainerSpacing()
    }
    
    func trackUnLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if notificationTrack === objectValue {
            track.loved = false
            loveButton.selected = false
        }
        updateLoveContainerSpacing()
    }
    
    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
        Analytics.trackButtonClick("Playlist Play/Pause")
        switch playState {
        case .Playing:
            AudioPlayer.sharedInstance.pause()
        case .Paused, .NotPlaying:
            AudioPlayer.sharedInstance.playNewTrack(track, dataSource: dataSource)
        }
    }
    
    @IBAction func infoButtonClicked(sender: TransparentButton) {
        Analytics.trackButtonClick("Playlist Info")
        if trackInfoWindowController == nil {
            let trackInfoStoryboard = NSStoryboard(name: "TrackInfo", bundle: nil)!
            trackInfoWindowController = trackInfoStoryboard.instantiateInitialController() as? NSWindowController
            var trackInfoViewController = trackInfoWindowController!.window!.contentViewController!
            trackInfoViewController.representedObject = objectValue
        }
        trackInfoWindowController!.showWindow(self)
    }
    
    @IBAction func loveButtonClicked(sender: TransparentButton) {
        Analytics.trackButtonClick("Playlist Heart")
        let oldLovedValue = track.loved
        let newLovedValue = !oldLovedValue
        
        changeTrackLovedValueTo(newLovedValue)
        
        HypeMachineAPI.Requests.Me.toggleTrackFavorite(id: track.id, optionalParams: nil) {
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
        var viewController = TracksViewController(type: .LoveCount, title: track.artist, analyticsViewName: "MainWindow/SingleArtist")!
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
        viewController.dataSource = ArtistTracksDataSource(viewController: viewController, artistName: track.artist)
    }
    
    @IBAction func titleButtonClicked(sender: NSButton) {
        println("Track title clicked: \(track.title)")
    }
    
    func changeTrackLovedValueTo(loved: Bool) {
        if loved {
            Notifications.post(name: Notifications.TrackLoved, object: self, userInfo: ["track": track])
        } else {
            Notifications.post(name: Notifications.TrackUnLoved, object: self, userInfo: ["track": track])
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