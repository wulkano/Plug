//
//  FriendTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendTableCellView: IOSStyleTableCellView {
    @IBOutlet var avatarView: NSImageView!

    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
        }
    }
    var friendValue: Friend {
        return objectValue as Friend
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
        updateImage()
    }
    
    func updateImage() {
        avatarView.image = NSImage(named: "Avatar-Placeholder")
        if friendValue.avatarURL == nil { return }
        
        HypeMachineAPI.Friends.Avatar(friendValue,
            success: { image in
                self.avatarView.image = image
            }, failure: { error in
//                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
}
