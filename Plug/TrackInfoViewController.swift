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
    
    @IBAction func closeButtonClicked(sender: NSButton) {
        view.window!.close()
    }
    
    func representedObjectChanged() {
        updateAlbumArt()
        updatePostedCount()
        updatePostInfo()
    }
    
    func updateAlbumArt() {
        HypeMachineAPI.TrackThumbFor(representedTrack, preferedSize: .Medium,
            success: {image in
                self.albumArt.image = image
            },
            failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    func updatePostedCount() {
        postedCountTextField.stringValue = "Posted by \(representedTrack.postedCount) Blogs"
    }
    
    func updatePostInfo() {
        var postInfoAttributedString = NSMutableAttributedString()
        postInfoAttributedString.appendAttributedString(postInfoBlogName())
        postInfoAttributedString.appendAttributedString(postInfoDescription())
        postInfoAttributedString.appendAttributedString(postInfoDate())
        postInfoTextField.attributedStringValue = postInfoAttributedString
    }
    
    func postInfoBlogName() -> NSAttributedString {
        var string = representedTrack.postedBy
        var attributes = [NSObject: AnyObject]()
        var color = NSColor.whiteColor()
        var font = NSFont(name: "HelveticaNeue-Medium", size: 13)
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = font
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    func postInfoDescription() -> NSAttributedString {
        var string = " “\(representedTrack.postedByDescription)” "
        var attributes = [NSObject: AnyObject]()
        var color = NSColor.whiteColor().colorWithAlphaComponent(0.5)
        var font = NSFont(name: "HelveticaNeue", size: 13)
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = font
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    func postInfoDate() -> NSAttributedString {
        var string = "Jun 28th →"
        var attributes = [NSObject: AnyObject]()
        var color = NSColor.whiteColor()
        var font = NSFont(name: "HelveticaNeue-Medium", size: 13)
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = font
        return NSAttributedString(string: string, attributes: attributes)
    }
}