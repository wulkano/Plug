//
//  BasePlaylistTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BasePlaylistTableCellView: IOSStyleTableCellView {
    @IBOutlet var playPauseButton: HoverToggleButton!
    @IBOutlet var loveButton: TransparentButton!
    @IBOutlet var artistTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var titleTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var loveContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet var infoContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet var progressSlider: NSSlider!
    @IBOutlet var titleButton: HyperlinkButton!
    @IBOutlet var artistButton: HyperlinkButton!
    
    var trackInfoWindowController: NSWindowController?
    
    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
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
    var trackingProgress: Bool = false
    
    
    required override init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override func viewDidUnhide() {
        println("Unhide")
    }
    
    override func viewDidHide() {
        println("Hide")
    }
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }
    
    func initialSetup() {
        Notifications.Subscribe.TrackPlaying(self, selector: "trackPlaying:")
        Notifications.Subscribe.TrackPaused(self, selector: "trackPaused:")
        Notifications.Subscribe.TrackLoved(self, selector: "trackLoved:")
        Notifications.Subscribe.TrackUnLoved(self, selector: "trackUnLoved:")
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }

        playState = currentPlayState()
        updateTrackAvailability()
        updateTrackTitle()
        updateTrackArtist()
        mouseInside = false
        loveButton.selected = trackValue.loved
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
        switch trackValue.playlist!.type {
        case .Favorites:
            return false
        default:
            return true
        }
    }
    
    func trackProgress() {
        if trackingProgress == false {
            Notifications.Subscribe.TrackProgressUpdated(self, selector: "progressUpdated:")
        }
        trackingProgress = true
    }
    
    func untrackProgress() {
        Notifications.Unsubscribe.TrackProgressUpdated(self)
        trackingProgress = false
    }
    
    func trackPlaying(notification: NSNotification) {
        let track = Notifications.Read.TrackNotification(notification)
        if track === objectValue {
            playState = PlayState.Playing
        } else {
            playState = PlayState.NotPlaying
        }
    }
    
    func trackPaused(notification: NSNotification) {
        let track = Notifications.Read.TrackNotification(notification)
        if track === objectValue {
            playState = PlayState.Paused
        }
    }
    
    func trackLoved(notification: NSNotification) {
        let track = Notifications.Read.TrackNotification(notification)
        if track === objectValue {
            trackValue.loved = true
            loveButton.selected = true
        }
        updateLoveContainerSpacing()
    }
    
    func trackUnLoved(notification: NSNotification) {
        let track = Notifications.Read.TrackNotification(notification)
        if track === objectValue {
            trackValue.loved = false
            loveButton.selected = false
        }
        updateLoveContainerSpacing()
    }
    
    @IBAction func playPauseButtonClicked(sender: HoverToggleButton) {
        Analytics.sharedInstance.trackButtonClick("Playlist Play/Pause")
        switch playState {
        case .Playing:
            AudioPlayer.sharedInstance.pause()
        case .Paused, .NotPlaying:
            AudioPlayer.sharedInstance.play(trackValue)
        }
    }
    
    @IBAction func infoButtonClicked(sender: TransparentButton) {
        Analytics.sharedInstance.trackButtonClick("Playlist Info")
        if trackInfoWindowController == nil {
            trackInfoWindowController = NSStoryboard(name: "TrackInfo", bundle: nil)!.instantiateInitialController() as? NSWindowController
            var trackInfoViewController = trackInfoWindowController!.window!.contentViewController!
            trackInfoViewController.representedObject = objectValue
        }
        trackInfoWindowController!.showWindow(self)
    }
    
    @IBAction func loveButtonClicked(sender: TransparentButton) {
        Analytics.sharedInstance.trackButtonClick("Playlist Heart")
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
    
    @IBAction func artistButtonClicked(sender: NSButton) {
        var viewController = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("BasePlaylistViewController") as BasePlaylistViewController
        viewController.title = trackValue.artist
        viewController.defaultAnalyticsViewName = "MainWindow/SingleArtist"
        Notifications.Post.PushViewController(viewController, sender: self)
        viewController.dataSource = ArtistPlaylistDataSource(artistName: trackValue.artist, viewController: viewController)
    }
    
    @IBAction func titleButtonClicked(sender: NSButton) {
        println("Track title clicked: \(trackValue.title)")
    }
    
    func changeTrackLovedValueTo(loved: Bool) {
        if loved {
            Notifications.Post.TrackLoved(trackValue, sender: self)
        } else {
            Notifications.Post.TrackUnLoved(trackValue, sender: self)
        }
    }
    
    func progressUpdated(notification: NSNotification) {
        let update = Notifications.Read.TrackProgressNotification(notification)
        progressSlider.doubleValue = update.progress / update.duration
    }
    
    enum PlayState {
        case Playing
        case Paused
        case NotPlaying
    }
}