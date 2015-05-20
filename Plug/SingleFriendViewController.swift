//
//  SingleFriendViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import Alamofire

class SingleFriendViewController: BaseContentViewController {
    @IBOutlet var avatarView: NSImageView!
    @IBOutlet weak var backgroundView: BackgroundBorderView!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var favoritesCountTextField: NSTextField!
    @IBOutlet weak var friendsCountTextField: NSTextField!
    @IBOutlet var playlistContainer: NSView!
    override var analyticsViewName: String {
        return "MainWindow/SingleFriend"
    }
    
    var playlistViewController: BasePlaylistViewController!

    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedFriend: HypeMachineAPI.User {
        return representedObject as! HypeMachineAPI.User
    }
    
    func representedObjectChanged() {
        if representedObject == nil { return }
        
        updateImage()
        updateUsername()
        updateFavoritesCount()
        updateFriendsCount()
        loadPlaylist()
        removeLoaderView()
    }
    
    func updateImage() {
        if representedFriend.avatarURL == nil { return }
        
        Alamofire.request(.GET, representedFriend.avatarURL!).validate().responseImage {
            (_, _, image, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                Logger.LogError(error!)
                return
            }
            
            self.avatarView.image = image
        }
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
        playlistViewController = storyboard!.instantiateControllerWithIdentifier("BasePlaylistViewController") as! BasePlaylistViewController
        addChildViewController(playlistViewController)
        ViewPlacementHelper.AddFullSizeSubview(playlistViewController.view, toSuperView: playlistContainer)
        playlistViewController.dataSource = FriendPlaylistDataSource(friend: representedFriend, viewController: playlistViewController)
    }
    
    override func addLoaderView() {
        loaderViewController = storyboard!.instantiateControllerWithIdentifier("SmallLoaderViewController") as? LoaderViewController
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        ViewPlacementHelper.AddSubview(loaderViewController!.view, toSuperView: backgroundView, withInsets: insets)
    }
    
    override func refresh() {
        playlistViewController.refresh()
    }
}
