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
    @IBOutlet var hoverSectionWidthConstraint: NSLayoutConstraint!
    
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
    }
    
    func objectValueChanged() {
        mouseInside = false
        hoverSectionWidthConstraint.constant = 0
        if AudioPlayer.sharedInstance.currentTrack === objectValue {
            if AudioPlayer.sharedInstance.playing {
                playState = PlayState.Playing
            } else {
                playState = PlayState.Paused
            }
        } else {
            playState = PlayState.NotPlaying
        }
    }
    
    func mouseInsideChanged() {
        if mouseInside {
            playPauseButton.hidden = false
            hoverSectionWidthConstraint.constant = 80
        } else {
            if playState == PlayState.NotPlaying {
                playPauseButton.hidden = true
            }
            hoverSectionWidthConstraint.constant = 0
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
        if notificationTrack === trackValue {
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
    
    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
        switch playState {
        case .Playing:
            AudioPlayer.sharedInstance.pause()
        case .Paused, .NotPlaying:
            AudioPlayer.sharedInstance.play(trackValue)
        }
    }
    
    enum PlayState {
        case Playing
        case Paused
        case NotPlaying
    }
}