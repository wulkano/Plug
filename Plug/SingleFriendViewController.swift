//
//  SingleFriendViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SingleFriendViewController: NSViewController {
    @IBOutlet var avatarView: NSImageView!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var favoritesCountTextField: NSTextField!
    @IBOutlet weak var friendsCountTextField: NSTextField!
    @IBOutlet var playlistContainer: NSView!
    
    var playlistViewController: BasePlaylistViewController!

    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedFriend: Friend {
        return representedObject as Friend
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    func representedObjectChanged() {
        if representedObject == nil { return }
        
        updateImage()
        updateUsername()
        updateFavoritesCount()
        updateFriendsCount()
        loadPlaylist()
    }
    
    func updateImage() {
        if representedFriend.avatarURL == nil { return }
        
        HypeMachineAPI.Friends.Avatar(representedFriend,
            success: { image in
                self.avatarView.image = image
            }, failure: { error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
        })
    }
    
    func updateUsername() {
        usernameTextField.stringValue = representedFriend.username
    }
    
    func updateFavoritesCount() {
        favoritesCountTextField.integerValue = representedFriend.favoritesCount
    }
    
    func updateFriendsCount() {
        friendsCountTextField.integerValue = representedFriend.followersCount
    }
    
    func loadPlaylist() {
        playlistViewController = storyboard.instantiateControllerWithIdentifier("BasePlaylistViewController") as BasePlaylistViewController
        addChildViewController(playlistViewController)
        ViewPlacementHelper.AddFullSizeSubview(playlistViewController.view, toSuperView: playlistContainer)
        playlistViewController.dataSource = FriendPlaylistDataSource(friend: representedFriend, viewController: playlistViewController)
    }
}
