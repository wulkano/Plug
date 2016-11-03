//
//  FeedTrackTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import SnapKit

class FeedTrackTableCellView: LoveCountTrackTableCellView {
    let sourceTypeColor = NSColor(red256: 175, green256: 179, blue256: 181)
    let sourceColor = NSColor(red256: 138, green256: 146, blue256: 150)
    
    var sourceTypeTextField: SelectableTextField!
//    @IBOutlet var sourceButtonTrailingConstraint: NSLayoutConstraint!
    var sourceButton: HyperlinkButton!
//    var sourceTypeTextFieldWidthConstraint: Constraint!
    
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
        
        if track.audioUnavailable {
            sourceTypeTextField.textColor = disabledArtistColor
            sourceButton.textColor = disabledArtistColor
        } else {
            sourceTypeTextField.textColor = sourceTypeColor
            sourceButton.textColor = sourceColor
        }
    }
    
    func updateSourceType() {
        if track.viaUser != nil {
            sourceTypeTextField.stringValue = "Loved by"
        } else if track.viaQuery != nil {
            sourceTypeTextField.stringValue = "Matched query"
        } else {
            sourceTypeTextField.stringValue = "Posted by"
        }
        
//        sourceTypeTextFieldWidthConstraint.updateOffset(sourceTypeTextField.attributedStringValue.size.width + 1.5)
        
        switch playState {
        case .playing, .paused:
            sourceTypeTextField.selected = true
        case .notPlaying:
            sourceTypeTextField.selected = false
        }
    }
    
    func updateSource() {
        if track.viaUser != nil {
            sourceButton.title = track.viaUser!
        } else if track.viaQuery != nil {
            sourceButton.title = track.viaQuery! + " →"
        } else {
            sourceButton.title = track.postedBy
        }
        
        switch playState {
        case .playing, .paused:
            sourceButton.selected = true
        case .notPlaying:
            sourceButton.selected = false
        }
    }

//    override func updateTextFieldsSpacing() {
//        super.updateTextFieldsSpacing()
//        
//        var mouseOutSpacing: CGFloat = 32
//        var mouseInSpacing: CGFloat = 20
//        
//        if mouseInside {
//            sourceButtonTrailingConstraint.constant = mouseInSpacing
//        } else {
//            sourceButtonTrailingConstraint.constant = mouseOutSpacing
//        }
//    }
    
    @IBAction func sourceButtonClicked(_ sender: NSButton) {
        if track.viaUser != nil {
            loadSingleFriendPage()
        } else if track.viaQuery != nil {
            loadQuery()
        } else {
            loadSingleBlogPage()
        }
    }
    
    func loadSingleFriendPage() {
        let viewController = UserViewController(username: track.viaUser!)!
        NavigationController.sharedInstance!.pushViewController(viewController, animated: true)
    }
    
    func loadQuery() {
        let url = URL(string: "http://hypem.com/search/\(track.viaQuery!)")!
        NSWorkspace.shared().open(url)
    }
    
    func loadSingleBlogPage() {
        let viewController = BlogViewController(blogID: track.postedById, blogName: track.postedBy)!
        NavigationController.sharedInstance!.pushViewController(viewController, animated: true)
    }
}
