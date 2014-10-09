//
//  TrackInfoViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TrackInfoViewController: NSViewController, TagContainerViewDelegate {
    @IBOutlet weak var albumArt: NSImageView!
    @IBOutlet weak var postedCountTextField: NSTextField!
    @IBOutlet weak var loveButton: TransparentButton!
    @IBOutlet weak var tagContainer: TagContainerView!
    @IBOutlet weak var postedByTextField: NSTextField!
    @IBOutlet weak var seeMoreButton: NSButton!
    @IBOutlet weak var postInfoPlaceholder: NSButton!
    
    var postInfoTextView: NSTextView!
    
    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedTrack: Track {
        return representedObject as Track
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Notifications.Subscribe.TrackLoved(self, selector: "trackLoved:")
        Notifications.Subscribe.TrackUnLoved(self, selector: "trackUnLoved:")
        tagContainer.delegate = self
        
        Analytics.sharedInstance.trackView("TrackInfoWindow")
        
        setupPostInfoTextView()
    }
    
    func setupPostInfoTextView() {
        postInfoTextView = NSTextView(frame: NSZeroRect)
        postInfoTextView.drawsBackground = false
        postInfoTextView.selectable = true
        postInfoTextView.editable = false
        postInfoTextView.textContainerInset = NSZeroSize
        
        postInfoTextView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postInfoTextView)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-26-[view]-26-|", options: nil, metrics: nil, views: ["view": postInfoTextView])
        view.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topView]-10-[view]-12-[bottomView]", options: nil, metrics: nil, views: ["topView": postedByTextField, "view": postInfoTextView, "bottomView": seeMoreButton])
        view.addConstraints(constraints)
    }
    
    @IBAction func closeButtonClicked(sender: NSButton) {
        view.window!.close()
    }
    
    @IBAction func loveButtonClicked(sender: NSButton) {
        Analytics.sharedInstance.trackButtonClick("Track Info Heart")
        
        let oldLovedValue = representedTrack.loved
        let newLovedValue = !oldLovedValue
        
        changeTrackLovedValueTo(newLovedValue)
        
        HypeMachineAPI.Tracks.ToggleLoved(representedTrack,
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
    
    func genreButtonClicked(genre: Genre) {
        loadSingleGenreView(genre)
    }
    
    func loadSingleGenreView(genre: Genre) {
        var viewController = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("BasePlaylistViewController") as BasePlaylistViewController
        viewController.title = genre.name
        Notifications.Post.PushViewController(viewController, sender: self)
        viewController.dataSource = GenrePlaylistDataSource(genre: genre, viewController: viewController)
    }
    
    @IBAction func downloadITunesButtonClicked(sender: NSButton) {
        Analytics.sharedInstance.trackButtonClick("Track Info Download iTunes")

        NSWorkspace.sharedWorkspace().openURL(representedTrack.iTunesURL)
    }
    
    @IBAction func postInfoClicked(sender: NSButton) {
        Analytics.sharedInstance.trackButtonClick("Track Info Blog Description")
    }
    
    @IBAction func seeMoreButtonClicked(sender: NSButton) {
        Analytics.sharedInstance.trackButtonClick("Track Info See More")
        
        NSWorkspace.sharedWorkspace().openURL(representedTrack.hypeMachineURL())
    }
    
    func trackLoved(notification: NSNotification) {
        let track = Notifications.Read.TrackNotification(notification)
        if track === representedObject {
            representedTrack.loved = track.loved
            updateLoveButton()
        }
    }
    
    func trackUnLoved(notification: NSNotification) {
        let track = Notifications.Read.TrackNotification(notification)
        if track === representedTrack {
            representedTrack.loved = track.loved
            updateLoveButton()
        }
    }
    
    func changeTrackLovedValueTo(loved: Bool) {
        representedTrack.loved = loved
        if loved {
            Notifications.Post.TrackLoved(representedTrack, sender: self)
        } else {
            Notifications.Post.TrackUnLoved(representedTrack, sender: self)
        }
    }

    func representedObjectChanged() {
        updateAlbumArt()
        updatePostedCount()
        updatePostInfo()
        updateLoveButton()
        updateTags()
    }
    
    func updateAlbumArt() {
        HypeMachineAPI.Tracks.Thumb(representedTrack, preferedSize: .Medium,
            success: { image in
                self.albumArt.image = image
            }, failure: { error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    func updatePostedCount() {
        postedCountTextField.stringValue = "Posted by \(representedTrack.postedCount) Blogs"
    }
    
    func updatePostInfo() {
        var postInfoAttributedString = PostInfoFormatter().attributedStringForPostInfo(representedTrack.postedBy, description: representedTrack.postedByDescription, datePosted: representedTrack.datePosted, url: representedTrack.hypeMachineURL())
        postInfoTextView.textStorage!.appendAttributedString(postInfoAttributedString)
    }
    
    func updateLoveButton() {
        loveButton.selected = representedTrack.loved
    }
    
    func updateTags() {
        tagContainer.tags = representedTrack.tags
    }
}