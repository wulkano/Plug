//
//  SingleUserViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import Alamofire

class SingleUserViewController: BaseContentViewController {
    @IBOutlet var avatarView: NSImageView!
    @IBOutlet weak var backgroundView: BackgroundBorderView!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var favoritesCountTextField: NSTextField!
    @IBOutlet weak var friendsCountTextField: NSTextField!
    @IBOutlet var playlistContainer: NSView!
    override var analyticsViewName: String {
        return "MainWindow/SingleFriend"
    }
    
    var tracksViewController: TracksViewController!

    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedUser: HypeMachineAPI.User {
        return representedObject as! HypeMachineAPI.User
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayActionButton = true
        actionButtonTarget = self
        actionButtonAction = "followButtonClicked:"
    }
    
    func representedObjectChanged() {
        if representedObject == nil { return }
        
        updateImage()
        updateUsername()
        updateFavoritesCount()
        updateFriendsCount()
        loadPlaylist()
        removeLoaderView()
        updateActionButton()
    }
    
    func updateImage() {
        if representedUser.avatarURL == nil { return }
        
        Alamofire.request(.GET, representedUser.avatarURL!).validate().responseImage {
            (_, _, image, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                return
            }
            
            self.avatarView.image = image
        }
    }
    
    func updateUsername() {
        usernameTextField.stringValue = representedUser.username
    }
    
    func updateFavoritesCount() {
        favoritesCountTextField.integerValue = representedUser.favoritesCount
    }
    
    func updateFriendsCount() {
        friendsCountTextField.integerValue = representedUser.followersCount
    }
    
    func loadPlaylist() {
        tracksViewController = storyboard!.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController
        addChildViewController(tracksViewController)
        playlistContainer.addSubview(tracksViewController.view)
        tracksViewController.view.snp_makeConstraints { make in
            make.edges.equalTo(playlistContainer)
        }
        tracksViewController.dataSource = UserTracksDataSource(viewController: tracksViewController, username: representedUser.username)
    }
    
    override func addLoaderView() {
        loaderViewController = storyboard!.instantiateControllerWithIdentifier("SmallLoaderViewController") as? LoaderViewController
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        backgroundView.addSubview(loaderViewController!.view)
        loaderViewController!.view.snp_makeConstraints { make in
            make.edges.equalTo(backgroundView).insets(insets)
        }
    }
    
    override func refresh() {
        tracksViewController.refresh()
    }
    
    func updateActionButton() {
        if representedUser.friend! == true {
            actionButton!.state = NSOnState
        } else {
            actionButton!.state = NSOffState
        }
    }
    
    func followButtonClicked(sender: ActionButton) {
        HypeMachineAPI.Requests.Me.toggleUserFavorite(id: representedUser.username, optionalParams: nil) { (favorited, error) in
            let favoritedState = sender.state == NSOnState
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                
                if sender.state == NSOffState {
                    sender.state = NSOnState
                } else {
                    sender.state = NSOffState
                }
                
                return
            }
            
            if favorited! != favoritedState {
                if favorited! {
                    sender.state = NSOnState
                } else {
                    sender.state = NSOffState
                }
            }
        }
    }
}
