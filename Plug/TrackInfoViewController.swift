//
//  TrackInfoViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TrackInfoViewController: NSViewController {
    @IBOutlet weak var albumArt: NSImageView!
    @IBOutlet weak var postedCountTextField: NSTextField!
    @IBOutlet var postInfoTextField: NSTextField!
    
    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedTrack: Track {
        return (representedObject as Track)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.sharedInstance.trackView("TrackInfoWindow")
    }
    
    @IBAction func closeButtonClicked(sender: NSButton) {
        view.window!.close()
    }
    
    func representedObjectChanged() {
        updateAlbumArt()
        updatePostedCount()
        updatePostInfo()
    }
    
    func updateAlbumArt() {
        HypeMachineAPI.Tracks.Thumb(representedTrack, preferedSize: .Medium,
            success: { image in
                self.albumArt.image = image
            },
            failure: { error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    func updatePostedCount() {
        postedCountTextField.stringValue = "Posted by \(representedTrack.postedCount) Blogs"
    }
    
    func updatePostInfo() {
        var postInfoAttributedString = PostInfoFormatter().attributedStringForPostInfo(representedTrack.postedBy, description: representedTrack.postedByDescription, datePosted: representedTrack.datePosted)
        postInfoTextField.attributedStringValue = postInfoAttributedString
    }
}