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

class UserViewController: BaseContentViewController {
    var user: HypeMachineAPI.User? {
        didSet { userChanged() }
    }
    
    var header: BackgroundBorderView!
    var avatarView: NSImageView!
    var usernameTextField: NSTextField!
    var favoritesCountTextField: NSTextField!
    var friendsCountTextField: NSTextField!
    var playlistContainer: NSView!
    
    var tracksViewController: TracksViewController!
    
    init?(user: HypeMachineAPI.User) {
        self.user = user
        super.init(title: user.username, analyticsViewName: "MainWindow/SingleUser")
        setup()
    }
    
    init?(username: String) {
        super.init(title: username, analyticsViewName: "MainWindow/SingleUser")
        loadUser(username)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        navigationItem.rightButton = NavigationItem.standardRightButtonWithOnStateTitle("Unfollow", offStateTitle: "Follow", target: self, action: "followButtonClicked:")
    }
    
    override func loadView() {
        super.loadView()
        
        header = BackgroundBorderView(frame: NSZeroRect)
        header.bottomBorder = true
        header.borderColor = NSColor(red256: 225, green256: 230, blue256: 233)
        header.background = true
        header.backgroundColor = NSColor.whiteColor()
        view.addSubview(header)
        header.snp_makeConstraints { make in
            make.height.equalTo(86)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        avatarView = CircleMaskImageView()
        avatarView.image = NSImage(named: "Avatar-Placeholder")!
        header.addSubview(avatarView)
        avatarView.snp_makeConstraints { make in
            make.centerY.equalTo(self.header)
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.left.equalTo(self.header).offset(17)
        }
        
        usernameTextField = NSTextField()
        usernameTextField.editable = false
        usernameTextField.selectable = false
        usernameTextField.bordered = false
        usernameTextField.drawsBackground = false
        usernameTextField.font = NSFont(name: "HelveticaNeue", size: 20)!
        header.addSubview(usernameTextField)
        usernameTextField.snp_makeConstraints { make in
            make.height.equalTo(24)
            make.top.equalTo(self.header).offset(17)
            make.left.equalTo(self.avatarView.snp_right).offset(22)
            make.right.equalTo(self.header).offset(-20)
        }
        
        favoritesCountTextField = NSTextField()
        favoritesCountTextField.editable = false
        favoritesCountTextField.selectable = false
        favoritesCountTextField.bordered = false
        favoritesCountTextField.drawsBackground = false
        favoritesCountTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        header.addSubview(favoritesCountTextField)
        favoritesCountTextField.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp_bottom).offset(8)
            make.left.equalTo(self.avatarView.snp_right).offset(22)
        }
        
        let favoritesLabel = NSTextField()
        favoritesLabel.editable = false
        favoritesLabel.selectable = false
        favoritesLabel.bordered = false
        favoritesLabel.drawsBackground = false
        favoritesLabel.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        favoritesLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        favoritesLabel.stringValue = "Favorites"
        header.addSubview(favoritesLabel)
        favoritesLabel.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp_bottom).offset(8)
            make.left.equalTo(self.favoritesCountTextField.snp_right).offset(3)
        }
        
        friendsCountTextField = NSTextField()
        friendsCountTextField.editable = false
        friendsCountTextField.selectable = false
        friendsCountTextField.bordered = false
        friendsCountTextField.drawsBackground = false
        friendsCountTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        header.addSubview(friendsCountTextField)
        friendsCountTextField.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp_bottom).offset(8)
            make.left.equalTo(favoritesLabel.snp_right).offset(13)
        }
        
        let friendsLabel = NSTextField()
        friendsLabel.editable = false
        friendsLabel.selectable = false
        friendsLabel.bordered = false
        friendsLabel.drawsBackground = false
        friendsLabel.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        friendsLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        friendsLabel.stringValue = "Friends"
        header.addSubview(friendsLabel)
        friendsLabel.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp_bottom).offset(8)
            make.left.equalTo(self.friendsCountTextField.snp_right).offset(3)
        }
        
        playlistContainer = NSView()
        view.addSubview(playlistContainer)
        playlistContainer.snp_makeConstraints { make in
            make.top.equalTo(self.header.snp_bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user != nil { userChanged() }
    }
    
    func loadUser(username: String) {
        HypeMachineAPI.Requests.Users.show(username: username) {
            (user, error) in
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error)
                return
            }
            
            self.user = user
        }
    }
    
    func userChanged() {
        updateImage()
        updateUsername()
        updateFavoritesCount()
        updateFriendsCount()
        loadPlaylist()
        removeLoaderView()
        updateActionButton()
    }
    
    func updateImage() {
        if user!.avatarURL == nil { return }
        
        Alamofire.request(.GET, user!.avatarURL!).validate().responseImage {
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
        usernameTextField.stringValue = user!.username
    }
    
    func updateFavoritesCount() {
        favoritesCountTextField.integerValue = user!.favoritesCount
    }
    
    func updateFriendsCount() {
        friendsCountTextField.integerValue = user!.followersCount
    }
    
    func loadPlaylist() {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))!
        tracksViewController = TracksViewController(type: .LoveCount, title: "", analyticsViewName: "User/Tracks")
        addChildViewController(tracksViewController)
        playlistContainer.addSubview(tracksViewController.view)
        tracksViewController.view.snp_makeConstraints { make in
            make.edges.equalTo(playlistContainer)
        }
        tracksViewController.dataSource = UserTracksDataSource(viewController: tracksViewController, username: user!.username)
    }
    
    func updateActionButton() {
        if user!.friend! == true {
            navigationItem!.rightButton!.state = NSOnState
        } else {
            navigationItem!.rightButton!.state = NSOffState
        }
    }
    
    func followButtonClicked(sender: ActionButton) {
        HypeMachineAPI.Requests.Me.toggleUserFavorite(id: user!.username, optionalParams: nil) { (favorited, error) in
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
    
    // MARK: BaseContentViewController
    
    override func addLoaderView() {
        loaderViewController = LoaderViewController(size: .Small)
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        header.addSubview(loaderViewController!.view)
        loaderViewController!.view.snp_makeConstraints { make in
            make.edges.equalTo(self.header).insets(insets)
        }
    }
    
    override func refresh() {
        tracksViewController.refresh()
    }
    
    override var shouldShowStickyTrack: Bool {
        return false
    }
}
