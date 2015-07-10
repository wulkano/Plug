//
//  FeedTrackTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class FeedTrackTableCellView: LoveCountTrackTableCellView {
    let sourceTypeColor = NSColor(red256: 175, green256: 179, blue256: 181)
    let sourceColor = NSColor(red256: 138, green256: 146, blue256: 150)
    
    @IBOutlet var sourceTypeTextField: SelectableTextField!
    @IBOutlet var sourceButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var sourceButton: HyperlinkButton!
    @IBOutlet var sourceTypeTextFieldWidthConstraint: NSLayoutConstraint!
    
    override func objectValueChanged() {
        super.objectValueChanged()
        if objectValue == nil { return }
        
        updateSourceType()
        updateSource()
    }
    
    override func playStateChanged() {
        super.playStateChanged()
        
        updateSourceType()
        updateSource()
    }
    
    override func updateTrackAvailability() {
        super.updateTrackAvailability()
        
        if trackValue.audioUnavailable {
            sourceTypeTextField.textColor = disabledArtistColor
            sourceButton.textColor = disabledArtistColor
        } else {
            sourceTypeTextField.textColor = sourceTypeColor
            sourceButton.textColor = sourceColor
        }
    }
    
    func updateSourceType() {
        if trackValue.viaUser != nil {
            sourceTypeTextField.stringValue = "Loved by"
        } else if trackValue.viaQuery != nil {
            sourceTypeTextField.stringValue = "Matched query"
        } else {
            sourceTypeTextField.stringValue = "Posted by"
        }
        
        sourceTypeTextFieldWidthConstraint.constant = sourceTypeTextField.attributedStringValue.size.width + 1.5
        
        switch playState {
        case .Playing, .Paused:
            sourceTypeTextField.selected = true
        case .NotPlaying:
            sourceTypeTextField.selected = false
        }
    }
    
    func updateSource() {
        if trackValue.viaUser != nil {
            sourceButton.title = trackValue.viaUser!
        } else if trackValue.viaQuery != nil {
            sourceButton.title = trackValue.viaQuery! + " →"
        } else {
            sourceButton.title = trackValue.postedBy
        }
        
        switch playState {
        case .Playing, .Paused:
            sourceButton.selected = true
        case .NotPlaying:
            sourceButton.selected = false
        }
    }

    override func updateTextFieldsSpacing() {
        super.updateTextFieldsSpacing()
        
        var mouseOutSpacing: CGFloat = 32
        var mouseInSpacing: CGFloat = 20
        
        if mouseInside {
            sourceButtonTrailingConstraint.constant = mouseInSpacing
        } else {
            sourceButtonTrailingConstraint.constant = mouseOutSpacing
        }
    }
    
    @IBAction func usernameOrBlogNameClicked(sender: NSButton) {
        if trackValue.viaUser != nil {
            loadSingleFriendPage()
        } else if trackValue.viaQuery != nil {
            loadQuery()
        } else {
            loadSingleBlogPage()
        }
    }
    
    func loadSingleFriendPage() {
        var viewController = UserViewController(username: trackValue.viaUser!)
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
    }
    
    func loadQuery() {
        let url = NSURL(string: "http://hypem.com/search/\(trackValue.viaQuery!)")!
        NSWorkspace.sharedWorkspace().openURL(url)
    }
    
    func loadSingleBlogPage() {
        var viewController = BlogViewController(blogID: trackValue.postedById, blogName: trackValue.postedBy)
        Notifications.post(name: Notifications.PushViewController, object: self, userInfo: ["viewController": viewController])
    }
}
