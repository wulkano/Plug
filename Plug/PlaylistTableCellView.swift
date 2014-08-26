//
//  PlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistTableCellView: NSTableCellView {
    @IBOutlet var playPauseButton: HoverToggleButton!
    @IBOutlet var loveButton: TransparentButton!
    @IBOutlet var artistTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var loveContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet var infoContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet var progressSlider: NSSlider!
    @IBOutlet var loveCount: NSView!
    
    var trackInfoWindowController: NSWindowController?
    var trackInfoWindow: NSWindow?
    var trackInfoViewController: TrackInfoViewController?

    
    override var backgroundStyle: NSBackgroundStyle {
        get { return NSBackgroundStyle.Light }
        set {}
    }
    override var objectValue: AnyObject! {
        didSet {
            if objectValue != nil {
                objectValueChanged()
            }
        }
    }
    var mouseInside: Bool = false {
        didSet{ mouseInsideChanged() }
    }
    var playState: PlayState = PlayState.NotPlaying {
        didSet { playStateChanged() }
    }
    var trackValue: Track {
        return objectValue as Track
    }

    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }

    deinit {
        Notifications.UnsubscribeAll(self)
    }
    
    func initialSetup() {
        Notifications.Subscribe.TrackPlaying(self, selector: "trackPlaying:")
        Notifications.Subscribe.TrackPaused(self, selector: "trackPaused:")
        Notifications.Subscribe.TrackLoved(self, selector: "trackLoved:")
        Notifications.Subscribe.TrackUnLoved(self, selector: "trackUnLoved:")
    }
    
    func objectValueChanged() {
        mouseInside = false
        if AudioPlayer.sharedInstance.currentTrack === objectValue {
            if AudioPlayer.sharedInstance.playing {
                playState = PlayState.Playing
            } else {
                playState = PlayState.Paused
            }
        } else {
            playState = PlayState.NotPlaying
        }
        loveButton.selected = trackValue.loved
        progressSlider.doubleValue = 0
    }
    
    func mouseInsideChanged() {
        updatePlayPauseButtonVisibility()
        updateTextFieldsSpacing()
        updateLoveContainerSpacing()
        updateInfoContainerSpacing()
    }
    
    func updatePlayPauseButtonVisibility() {
        // TODO: Consolidate loveCount hidden with playstate
        // below
        if mouseInside {
            playPauseButton.hidden = false
            loveCount.hidden = true
        } else {
            if playState == PlayState.NotPlaying {
                playPauseButton.hidden = true
                loveCount.hidden = false
            }
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
        switch trackValue.playlist!.type {
        case .Popular, .Latest, .Feed, .Search:
            return true
        case .Favorites:
            return false
        }
    }
    
    func playStateChanged() {
        // TODO: Maybe consolidate with mouse inside stuff
        switch playState {
        case .Playing:
            playPauseButton.selected = true
            playPauseButton.hidden = false
            progressSlider.hidden = false
            loveCount.hidden = true
            trackProgress()
        case .Paused:
            playPauseButton.selected = false
            playPauseButton.hidden = false
            progressSlider.hidden = false
            loveCount.hidden = true
            trackProgress()
        case .NotPlaying:
            playPauseButton.selected = false
            playPauseButton.hidden = true
            progressSlider.hidden = true
            progressSlider.doubleValue = 0
            loveCount.hidden = false
            untrackProgress()
        }
    }
    
    func trackProgress() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "progressUpdated:", name: Notifications.TrackProgressUpdated, object: nil)
    }
    
    func untrackProgress() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Notifications.TrackProgressUpdated, object: nil)
    }

    func trackPlaying(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as Track
        if notificationTrack === objectValue {
            playState = PlayState.Playing
        } else {
            playState = PlayState.NotPlaying
        }
    }
    
    func trackPaused(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as Track
        if notificationTrack === objectValue {
            playState = PlayState.Paused
        }
    }
    
    func trackLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as Track
        if notificationTrack === objectValue {
            trackValue.loved = true
            loveButton.selected = true
        }
    }
    
    func trackUnLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo!["track"] as Track
        if notificationTrack === objectValue {
            trackValue.loved = false
            loveButton.selected = false
        }
    }
    
    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
        switch playState {
        case .Playing:
            // TODO: Go the notifications route
            AudioPlayer.sharedInstance.pause()
        case .Paused, .NotPlaying:
            AudioPlayer.sharedInstance.play(trackValue)
        }
    }
    
    @IBAction func infoButtonClicked(sender: TransparentButton) {
    }
    
    @IBAction func loveButtonClicked(sender: TransparentButton) {
        let oldLovedValue = trackValue.loved
        let newLovedValue = !oldLovedValue
        
        changeTrackLovedValueTo(newLovedValue)
        
        HypeMachineAPI.Tracks.ToggleLoved(trackValue,
            success: {loved in
                if loved != newLovedValue {
                    self.changeTrackLovedValueTo(loved)
                }
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
                self.changeTrackLovedValueTo(oldLovedValue)
        })
    }
    
    @IBAction func progressSliderDragged(sender: NSSlider) {
        AudioPlayer.sharedInstance.seekToPercent(sender.doubleValue)
    }
    
    func changeTrackLovedValueTo(loved: Bool) {
        if loved == true {
            Notifications.Post.TrackLoved(trackValue, sender: self)
        } else {
            Notifications.Post.TrackUnLoved(trackValue, sender: self)
        }
    }
    
    func progressUpdated(notification: NSNotification) {
        let progress = (notification.userInfo!["progress"] as NSNumber).doubleValue
        let duration = (notification.userInfo!["duration"] as NSNumber).doubleValue
        progressSlider.doubleValue = progress / duration
    }
    
    enum PlayState {
        case Playing
        case Paused
        case NotPlaying
    }
}