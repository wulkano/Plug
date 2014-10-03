//
//  FeedTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FeedPlaylistTableCellView: LoveCountPlaylistTableCellView {
    @IBOutlet var usernameOrBlogNameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var lovedByOrPostedByWidthConstraint: NSLayoutConstraint!
    @IBOutlet var lovedByOrPostedBy: SelectableTextField!
    @IBOutlet var usernameOrBlogNameButton: HyperlinkButton!
    
    override func objectValueChanged() {
        super.objectValueChanged()
        if objectValue == nil { return }
        
        updateLovedByOrPostedBy()
        updateUsernameOrBlogName()
    }
    
    override func playStateChanged() {
        super.playStateChanged()
        
        updateLovedByOrPostedBy()
        updateUsernameOrBlogName()
    }
    
    func updateLovedByOrPostedBy() {
        var lovedByWidth: CGFloat = 52
        var postedByWidth: CGFloat = 57
        
        if trackValue.lovedBy != nil {
            lovedByOrPostedByWidthConstraint.constant = lovedByWidth
            lovedByOrPostedBy.stringValue = "Loved by"
            usernameOrBlogNameButton.title = trackValue.lovedBy
        } else {
            lovedByOrPostedByWidthConstraint.constant = postedByWidth
            lovedByOrPostedBy.stringValue = "Posted by"
            usernameOrBlogNameButton.title = trackValue.postedBy
        }
        
        switch playState {
        case .Playing, .Paused:
            lovedByOrPostedBy.selected = true
        case .NotPlaying:
            lovedByOrPostedBy.selected = false
        }
    }
    
    func updateUsernameOrBlogName() {
        switch playState {
        case .Playing, .Paused:
            usernameOrBlogNameButton.selected = true
        case .NotPlaying:
            usernameOrBlogNameButton.selected = false
        }
    }

    override func updateTextFieldsSpacing() {
        super.updateTextFieldsSpacing()
        
        var mouseOutSpacing: CGFloat = 32
        var mouseInSpacing: CGFloat = 20
        
        if mouseInside {
            usernameOrBlogNameTrailingConstraint.constant = mouseInSpacing
        } else {
            usernameOrBlogNameTrailingConstraint.constant = mouseOutSpacing
        }
    }
    
    @IBAction func usernameOrBlogNameClicked(sender: NSButton) {
        if trackValue.lovedBy != nil {
            loadSingleFriendPage()
        } else {
            loadSingleBlogPage()
        }
    }
    
    func loadSingleFriendPage() {
        var viewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("SingleFriendViewController") as SingleFriendViewController
        Notifications.Post.PushViewController(viewController, sender: self)
        HypeMachineAPI.Friends.SingleFriend(trackValue.lovedBy!,
            success: { friend in
                viewController.representedObject = friend
            }, failure: { error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    func loadSingleBlogPage() {
        var viewController = NSStoryboard(name: "Main", bundle: nil).instantiateControllerWithIdentifier("SingleBlogViewController") as SingleBlogViewController
        Notifications.Post.PushViewController(viewController, sender: self)
        HypeMachineAPI.Blogs.SingleBlog(trackValue.postedById,
            success: { blog in
                viewController.representedObject = blog
            }, failure: { error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })

    }

}
