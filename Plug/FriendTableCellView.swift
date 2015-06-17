//
//  FriendTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import Alamofire

class FriendTableCellView: IOSStyleTableCellView {
    @IBOutlet var avatarView: NSImageView!
    @IBOutlet var fullNameTextField: NSTextField!
    @IBOutlet var usernameTextField: NSTextField!

    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
        }
    }
    var friendValue: HypeMachineAPI.User {
        return objectValue as! HypeMachineAPI.User
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
        updateFullName()
        updateUsername()
        updateImage()
    }
    
    func updateFullName() {
        fullNameTextField.stringValue = friendValue.fullName ?? friendValue.username
    }
    
    func updateUsername() {
        usernameTextField.stringValue = friendValue.username
    }
    
    func updateImage() {
        avatarView.image = NSImage(named: "Avatar-Placeholder")
        if friendValue.avatarURL == nil { return }
        
        Alamofire.request(.GET, friendValue.avatarURL!).validate().responseImage {
            (_, _, image, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                return
            }
            
            self.avatarView.image = image
        }
    }
}
