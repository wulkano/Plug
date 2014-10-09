//
//  TrackInfoViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TrackInfoViewController: NSViewController, TagContainerViewDelegate, PostInfoTextFieldDelegate {
    @IBOutlet weak var albumArt: NSImageView!
    @IBOutlet weak var postedCountTextField: NSTextField!
    @IBOutlet var postInfoTextField: PostInfoTextField!
    @IBOutlet weak var loveButton: TransparentButton!
    @IBOutlet weak var tagContainer: TagContainerView!
    
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
        postInfoTextField.postInfoDelegate = self
        
        Analytics.sharedInstance.trackView("TrackInfoWindow")
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
    
    func postInfoTextFieldClicked(sender: AnyObject) {
        Analytics.sharedInstance.trackButtonClick("Track Info Blog Description")
        
        NSWorkspace.sharedWorkspace().openURL(representedTrack.postURL)
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
        var postInfoAttributedString = PostInfoFormatter().attributedStringForPostInfo(representedTrack)
        postInfoTextField.attributedStringValue = postInfoAttributedString
    }
    
    func updateLoveButton() {
        loveButton.selected = representedTrack.loved
    }
    
    func updateTags() {
        tagContainer.tags = representedTrack.tags
    }
}