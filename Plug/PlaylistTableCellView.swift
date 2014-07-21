//
//  PlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistTableCellView: NSTableCellView {
    @IBOutlet var playPauseButton: HoverToggleButton
    override var objectValue: AnyObject! {
    didSet {
        if objectValue is Track {
            trackChanged()
        }
    }
    }
    override var backgroundStyle: NSBackgroundStyle {
        get { return NSBackgroundStyle.Light }
        set {}
    }
    var trackingArea: NSTrackingArea?
    var trackValue: Track {
        return objectValue as Track
    }
    var playState: PlayState = PlayState.NotPlaying {
    didSet {
        playStateChanged()
    }
    }
    
    init() {
        super.init()
        initialSetup()
    }
    
    init(coder: NSCoder!) {
        super.init(coder: coder)
        initialSetup()
    }
    
    init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialSetup()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func initialSetup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "newTrackPlaying:", name: Notifications.NewTrackPlaying, object: nil)
    }
    
    func trackChanged() {
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        ensureTrackingArea()
        if !trackingAreas.bridgeToObjectiveC().containsObject(trackingArea) {
            addTrackingArea(trackingArea)
        }
    }
    
    func ensureTrackingArea() {
        if !trackingArea {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited, owner: self, userInfo: nil)
        }
    }
    
    override func mouseEntered(theEvent: NSEvent!) {
        playPauseButton.hidden = false
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        if playState == PlayState.NotPlaying {
            playPauseButton.hidden = true
        }
    }
    
    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
        switch playState {
        case .Playing:
            playState = PlayState.Paused
        case .Paused:
            playState = PlayState.Playing
        case .NotPlaying:
            playState = PlayState.Playing
            NSNotificationCenter.defaultCenter().postNotificationName(Notifications.NewTrackPlaying, object: self, userInfo: ["track": trackValue])
        }
    }
    
    func newTrackPlaying(notification: NSNotification) {
        if notificationMatchesTrack(notification) {
            playState = PlayState.Playing
//            playPauseButton.buttonState = HoverToggleButton.ButtonState.Off
            return
        }
        playState = PlayState.NotPlaying
        playPauseButton.buttonState = HoverToggleButton.ButtonState.Off
    }
    
    func notificationMatchesTrack(notification: NSNotification) -> Bool {
        if let track = notification.userInfo["track"] as? Track {
            if track.id == trackValue.id {
                return true
            }
        }
        return false
    }
    
    func playStateChanged() {
        switch playState {
        case .Playing:
            playPauseButton.hidden = false
        case .Paused:
            playPauseButton.hidden = false
        case .NotPlaying:
            playPauseButton.hidden = true
        }
    }
    
    enum PlayState {
        case Playing
        case Paused
        case NotPlaying
    }
}
