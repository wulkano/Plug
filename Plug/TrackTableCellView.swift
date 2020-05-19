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
    let titleColor = NSColor.labelColor
    let artistColor = NSColor.secondaryLabelColor
    let disabledTitleColor = NSColor.tertiaryLabelColor
    let disabledArtistColor = NSColor.quaternaryLabelColor

    var playPauseButton: HoverToggleButton!
    var loveButton: TransparentButton!
    var loveContainerWidthConstraint: Constraint!
    var infoContainerWidthConstraint: Constraint!
    var progressSlider: NSSlider!
    var titleButton: HyperlinkButton!
    var artistButton: HyperlinkButton!
    var infoContainer: NSView!

    var showLoveButton: Bool = true

    var dataSource: TracksDataSource!
    var trackInfoWindowController: NSWindowController?

    override var objectValue: Any! {
        didSet { objectValueChanged() }
    }
    var track: HypeMachineAPI.Track {
        get { objectValue as! HypeMachineAPI.Track }
        set(newTrack) { objectValue = newTrack }
    }
    var mouseInside: Bool = false {
        didSet { mouseInsideChanged() }
    }
    var playState = PlayState.notPlaying {
        didSet { playStateChanged() }
    }
    var trackingProgress: Bool = false

    init() {
        super.init(frame: NSRect.zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        Notifications.unsubscribeAll(observer: self)
    }

    func setup() {
        Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackPlaying(_:)), name: Notifications.TrackPlaying, object: nil)
        Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackPaused(_:)), name: Notifications.TrackPaused, object: nil)
        Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackLoved(_:)), name: Notifications.TrackLoved, object: nil)
        Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackUnLoved(_:)), name: Notifications.TrackUnLoved, object: nil)
    }

    // Careful, since these cells are reused any async calls
    // may return when the cell represents a different track
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
        if AudioPlayer.sharedInstance.currentTrack == objectValue as? HypeMachineAPI.Track {
            if AudioPlayer.sharedInstance.playing {
                return PlayState.playing
            } else {
                return PlayState.paused
            }
        } else {
            return PlayState.notPlaying
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
        case .playing, .paused:
            titleButton.selected = true
        case .notPlaying:
            titleButton.selected = false
        }
    }

    func updateTrackArtist() {
        artistButton.title = track.artist
        switch playState {
        case .playing, .paused:
            artistButton.selected = true
        case .notPlaying:
            artistButton.selected = false
        }
    }

    func updatePlayPauseButtonVisibility() {
        if track.audioUnavailable {
            playPauseButton.isHidden = true
        } else if mouseInside {
            playPauseButton.isHidden = false
        } else {
            switch playState {
            case .playing, .paused:
                playPauseButton.isHidden = false
            case .notPlaying:
                playPauseButton.isHidden = true
            }
        }
    }

    func updatePlayPauseButtonSelected() {
        switch playState {
        case .playing:
            playPauseButton.selected = true
        case .paused, .notPlaying:
            playPauseButton.selected = false
        }
    }

    func updateProgressSliderVisibility() {
        switch playState {
        case .playing, .paused:
            progressSlider.isHidden = false
        case .notPlaying:
            progressSlider.isHidden = true
        }
    }

    func trackOrUntrackProgress() {
        switch playState {
        case .playing, .paused:
            trackProgress()
        case .notPlaying:
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
        let openWidth: CGFloat = 38
        let closedWidth: CGFloat = 0

        if mouseInside || (track.loved && showLoveButton) {
            loveContainerWidthConstraint.updateOffset(amount: openWidth)

//            loveContainerWidthConstraint.constant = openWidth
        } else {
			loveContainerWidthConstraint.updateOffset(amount: closedWidth)
//            loveContainerWidthConstraint.constant = closedWidth
        }
    }

    func updateInfoContainerSpacing() {
        let openWidth: CGFloat = 30
        let closedWidth: CGFloat = 0

        if mouseInside {
            infoContainerWidthConstraint.updateOffset(amount: openWidth)
//            infoContainerWidthConstraint.constant = openWidth
        } else {
           infoContainerWidthConstraint.updateOffset(amount: closedWidth)
//            infoContainerWidthConstraint.constant = closedWidth
        }
    }

    func trackProgress() {
        if trackingProgress == false {
            Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.progressUpdated(_:)), name: Notifications.TrackProgressUpdated, object: nil)
        }
        trackingProgress = true
    }

    func untrackProgress() {
        Notifications.unsubscribe(observer: self, name: Notifications.TrackProgressUpdated, object: self)
        trackingProgress = false
    }

	@objc func trackPlaying(_ notification: Notification) {
        if objectValue == nil { return }

        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if notificationTrack == objectValue as? HypeMachineAPI.Track {
            playState = PlayState.playing
        } else {
            playState = PlayState.notPlaying
        }
    }

	@objc func trackPaused(_ notification: Notification) {
        if objectValue == nil { return }

        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if notificationTrack == objectValue as? HypeMachineAPI.Track {
            playState = PlayState.paused
        }
    }

	@objc func trackLoved(_ notification: Notification) {
        if objectValue == nil { return }

        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if notificationTrack == objectValue as? HypeMachineAPI.Track {
            track.loved = true
            loveButton.selected = true
        }
        updateLoveContainerSpacing()
    }

	@objc func trackUnLoved(_ notification: Notification) {
        if objectValue == nil { return }

        let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if notificationTrack == objectValue as? HypeMachineAPI.Track {
            track.loved = false
            loveButton.selected = false
        }
        updateLoveContainerSpacing()
    }

    @IBAction func playPauseButtonClicked(_ sender: HoverToggleButton) {
        Analytics.trackButtonClick("Playlist Play/Pause")
        switch playState {
        case .playing:
            AudioPlayer.sharedInstance.pause()
        case .paused, .notPlaying:
            AudioPlayer.sharedInstance.playNewTrack(track, dataSource: dataSource)
        }
    }

    @IBAction func infoButtonClicked(_ sender: TransparentButton) {
        Analytics.trackButtonClick("Playlist Info")
        if trackInfoWindowController == nil {
            let trackInfoStoryboard = NSStoryboard(name: "TrackInfo", bundle: nil)
            trackInfoWindowController = trackInfoStoryboard.instantiateInitialController() as? NSWindowController
            let trackInfoViewController = trackInfoWindowController!.window!.contentViewController!
            trackInfoViewController.representedObject = objectValue
        }
        trackInfoWindowController!.showWindow(self)
    }

    @IBAction func loveButtonClicked(_ sender: TransparentButton) {
        Analytics.trackButtonClick("Playlist Heart")
        let oldLovedValue = track.loved
        let newLovedValue = !oldLovedValue

        changeTrackLovedValueTo(newLovedValue)

        HypeMachineAPI.Requests.Me.toggleTrackFavorite(id: track.id) { response in
            switch response.result {
            case .success(let favorited):
                if favorited != newLovedValue {
                    self.changeTrackLovedValueTo(favorited)
                }
            case .failure(let error):
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
                Swift.print(error as NSError)
                self.changeTrackLovedValueTo(oldLovedValue)
            }
        }
    }

    @IBAction func progressSliderDragged(_ sender: NSSlider) {
        AudioPlayer.sharedInstance.seekToPercent(sender.doubleValue)
    }

    @IBAction func artistButtonClicked(_ sender: NSButton) {
        let viewController = TracksViewController(type: .loveCount, title: track.artist, analyticsViewName: "MainWindow/SingleArtist")!
        viewController.dataSource = ArtistTracksDataSource(viewController: viewController, artistName: track.artist)
        NavigationController.sharedInstance!.pushViewController(viewController, animated: true)
    }

    @IBAction func titleButtonClicked(_ sender: NSButton) {
        Swift.print("Track title clicked: \(track.title)")
    }

    func changeTrackLovedValueTo(_ loved: Bool) {
        if loved {
            Notifications.post(name: Notifications.TrackLoved, object: self, userInfo: ["track" as NSObject: track])
        } else {
            Notifications.post(name: Notifications.TrackUnLoved, object: self, userInfo: ["track" as NSObject: track])
        }
    }

	@objc func progressUpdated(_ notification: Notification) {
        let progress = ((notification as NSNotification).userInfo!["progress"] as! NSNumber).doubleValue
        let duration = ((notification as NSNotification).userInfo!["duration"] as! NSNumber).doubleValue
        progressSlider.doubleValue = progress / duration
    }

    enum PlayState {
        case playing
        case paused
        case notPlaying
    }
}
