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

    
    override var backgroundStyle: NSBackgroundStyle {
        get { return NSBackgroundStyle.Light }
        set {}
    }
    override var objectValue: AnyObject! {
        didSet { objectValueChanged() }
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

    
    required init(coder: NSCoder!) {
        super.init(coder: coder)
        initialSetup()
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func initialSetup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "trackPlaying:", name: Notifications.TrackPlaying, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "trackPaused:", name: Notifications.TrackPaused, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "trackLoved:", name: Notifications.TrackLoved, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "trackUnLoved:", name: Notifications.TrackUnLoved, object: nil)
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
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
    }
    
    func mouseInsideChanged() {
        updatePlayPauseButtonVisibility()
        updateTitleAndArtistSpacing()
        updateLoveContainerSpacing()
        updateInfoContainerSpacing()
    }
    
    func updatePlayPauseButtonVisibility() {
        if mouseInside {
            playPauseButton.hidden = false
        } else {
            if playState == PlayState.NotPlaying {
                playPauseButton.hidden = true
            }
        }
    }
    
    func updateTitleAndArtistSpacing() {
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
        switch playState {
        case .Playing:
            playPauseButton.selected = true
            playPauseButton.hidden = false
        case .Paused:
            playPauseButton.selected = false
            playPauseButton.hidden = false
        case .NotPlaying:
            playPauseButton.selected = false
            playPauseButton.hidden = true
        }
    }

    func trackPlaying(notification: NSNotification) {
        let notificationTrack = notification.userInfo["track"] as Track
        if notificationTrack === objectValue {
            playState = PlayState.Playing
        } else {
            playState = PlayState.NotPlaying
        }
    }
    
    func trackPaused(notification: NSNotification) {
        let notificationTrack = notification.userInfo["track"] as Track
        if notificationTrack === objectValue {
            playState = PlayState.Paused
        }
    }
    
    func trackLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo["track"] as Track
        if notificationTrack === objectValue {
            trackValue.loved = true
            loveButton.selected = true
        }
    }
    
    func trackUnLoved(notification: NSNotification) {
        let notificationTrack = notification.userInfo["track"] as Track
        if notificationTrack === objectValue {
            trackValue.loved = false
            loveButton.selected = false
        }
    }
    
    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
        switch playState {
        case .Playing:
            AudioPlayer.sharedInstance.pause()
        case .Paused, .NotPlaying:
            AudioPlayer.sharedInstance.play(trackValue)
        }
    }
    
    @IBAction func infoButtonClicked(sender: TransparentButton) {
        // TODO:
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
                AppError.logError(error)
                self.changeTrackLovedValueTo(oldLovedValue)
        })
    }
    
    func changeTrackLovedValueTo(loved: Bool) {
        if loved == true {
            Notifications.Post.TrackLoved(trackValue, sender: self)
        } else {
            Notifications.Post.TrackUnLoved(trackValue, sender: self)
        }
    }
    
    enum PlayState {
        case Playing
        case Paused
        case NotPlaying
    }
}