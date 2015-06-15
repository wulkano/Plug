//
//  TrackInfoViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import Alamofire

class TrackInfoViewController: NSViewController, TagContainerViewDelegate, PostInfoTextFieldDelegate {
    @IBOutlet weak var titleTextField: VibrantTextField!
    @IBOutlet weak var artistTextField: VibrantTextField!
    @IBOutlet weak var loveCountTextField: VibrantTextField!
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
    var representedTrack: HypeMachineAPI.Track {
        return representedObject as! HypeMachineAPI.Track
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Notifications.subscribe(observer: self, selector: "trackLoved:", name: Notifications.TrackLoved, object: nil)
        Notifications.subscribe(observer: self, selector: "trackUnLoved:", name: Notifications.TrackUnLoved, object: nil)
        tagContainer.delegate = self
        postInfoTextField.postInfoDelegate = self
        
        Analytics.trackView("TrackInfoWindow")
    }
    
    @IBAction func closeButtonClicked(sender: NSButton) {
        view.window!.close()
    }
    
    @IBAction func loveButtonClicked(sender: NSButton) {
        Analytics.trackButtonClick("Track Info Heart")
        
        let oldLovedValue = representedTrack.loved
        let newLovedValue = !oldLovedValue
        
        changeTrackLovedValueTo(newLovedValue)
        
//        HypeMachineAPI.Tracks.ToggleLoved(representedTrack,
//            success: {loved in
//                if loved != newLovedValue {
//                    self.changeTrackLovedValueTo(loved)
//                }
//            }, failure: {error in
//                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
//                println(error)
//                self.changeTrackLovedValueTo(oldLovedValue)
//        })
    }
    
    func postInfoTextFieldClicked(sender: AnyObject) {
        Analytics.trackButtonClick("Track Info Blog Description")
        
        NSWorkspace.sharedWorkspace().openURL(representedTrack.postURL)
    }
    
    func tagButtonClicked(tag: HypeMachineAPI.Tag) {
        loadSingleTagView(tag)
    }
    
    func loadSingleTagView(tag: HypeMachineAPI.Tag) {
        var viewController = NSStoryboard(name: "Main", bundle: nil)!.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController
        viewController.title = tag.name
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
        viewController.dataSource = TagTracksDataSource(tagName: tag.name)
        viewController.dataSource!.viewController = viewController
    }
    
    @IBAction func downloadITunesButtonClicked(sender: NSButton) {
        Analytics.trackButtonClick("Track Info Download iTunes")

        NSWorkspace.sharedWorkspace().openURL(representedTrack.iTunesURL)
    }
    
    @IBAction func seeMoreButtonClicked(sender: NSButton) {
        Analytics.trackButtonClick("Track Info See More")
        
        NSWorkspace.sharedWorkspace().openURL(representedTrack.hypeMachineURL())
    }
    
    func trackLoved(notification: NSNotification) {
        let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if track === representedObject {
            representedTrack.loved = track.loved
            updateLoveButton()
        }
    }
    
    func trackUnLoved(notification: NSNotification) {
        let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
        if track === representedTrack {
            representedTrack.loved = track.loved
            updateLoveButton()
        }
    }
    
    func changeTrackLovedValueTo(loved: Bool) {
        representedTrack.loved = loved
        if loved {
            Notifications.post(name: Notifications.TrackLoved, object: self, userInfo: ["track": representedTrack])
        } else {
            Notifications.post(name: Notifications.TrackUnLoved, object: self, userInfo: ["track": representedTrack])
        }
    }

    func representedObjectChanged() {
        updateTitle()
        updateArtist()
        updateLoveCount()
        updateAlbumArt()
        updatePostedCount()
        updatePostInfo()
        updateLoveButton()
        updateTags()
    }
    
    func updateTitle() {
        titleTextField.stringValue = representedTrack.title
    }
    
    func updateArtist() {
        artistTextField.stringValue = representedTrack.artist
    }
    
    func updateLoveCount() {
        loveCountTextField.objectValue = representedTrack.lovedCountNum
    }
    
    func updateAlbumArt() {
        let url = representedTrack.thumbURLWithPreferedSize(.Medium)
        
        Alamofire.request(.GET, url).validate().responseImage {
            (_, _, image, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                return
            }
            
            self.albumArt.image = image
        }
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