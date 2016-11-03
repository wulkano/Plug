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
        navigationItem.rightButton = NavigationItem.standardRightButtonWithOnStateTitle("Unfollow", offStateTitle: "Follow", target: self, action: #selector(UserViewController.followButtonClicked(_:)))
    }
    
    override func loadView() {
        super.loadView()
        
        header = BackgroundBorderView(frame: NSZeroRect)
        header.bottomBorder = true
        header.borderColor = NSColor(red256: 225, green256: 230, blue256: 233)
        header.background = true
        header.backgroundColor = NSColor.white
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.height.equalTo(86)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        avatarView = CircleMaskImageView()
        avatarView.image = NSImage(named: "Avatar-Placeholder")!
        header.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.centerY.equalTo(self.header)
            make.width.equalTo(36)
            make.height.equalTo(36)
            make.left.equalTo(self.header).offset(17)
        }
        
        usernameTextField = NSTextField()
        usernameTextField.isEditable = false
        usernameTextField.isSelectable = false
        usernameTextField.isBordered = false
        usernameTextField.drawsBackground = false
        usernameTextField.font = appFont(size: 20)
        header.addSubview(usernameTextField)
        usernameTextField.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.top.equalTo(self.header).offset(17)
            make.left.equalTo(self.avatarView.snp.right).offset(22)
            make.right.equalTo(self.header).offset(-20)
        }
        
        favoritesCountTextField = NSTextField()
        favoritesCountTextField.isEditable = false
        favoritesCountTextField.isSelectable = false
        favoritesCountTextField.isBordered = false
        favoritesCountTextField.drawsBackground = false
        favoritesCountTextField.font = appFont(size: 13, weight: .medium)
        header.addSubview(favoritesCountTextField)
        favoritesCountTextField.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp.bottom).offset(8)
            make.left.equalTo(self.avatarView.snp.right).offset(22)
        }
        
        let favoritesLabel = NSTextField()
        favoritesLabel.isEditable = false
        favoritesLabel.isSelectable = false
        favoritesLabel.isBordered = false
        favoritesLabel.drawsBackground = false
        favoritesLabel.font = appFont(size: 13, weight: .medium)
        favoritesLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        favoritesLabel.stringValue = "Favorites"
        header.addSubview(favoritesLabel)
        favoritesLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp.bottom).offset(8)
            make.left.equalTo(self.favoritesCountTextField.snp.right).offset(3)
        }
        
        friendsCountTextField = NSTextField()
        friendsCountTextField.isEditable = false
        friendsCountTextField.isSelectable = false
        friendsCountTextField.isBordered = false
        friendsCountTextField.drawsBackground = false
        friendsCountTextField.font = appFont(size: 13, weight: .medium)
        header.addSubview(friendsCountTextField)
        friendsCountTextField.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp.bottom).offset(8)
            make.left.equalTo(favoritesLabel.snp.right).offset(13)
        }
        
        let friendsLabel = NSTextField()
        friendsLabel.isEditable = false
        friendsLabel.isSelectable = false
        friendsLabel.isBordered = false
        friendsLabel.drawsBackground = false
        friendsLabel.font = appFont(size: 13, weight: .medium)
        friendsLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        friendsLabel.stringValue = "Friends"
        header.addSubview(friendsLabel)
        friendsLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(self.usernameTextField.snp.bottom).offset(8)
            make.left.equalTo(self.friendsCountTextField.snp.right).offset(3)
        }
        
        playlistContainer = NSView()
        view.addSubview(playlistContainer)
        playlistContainer.snp.makeConstraints { make in
            make.top.equalTo(self.header.snp.bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user != nil { userChanged() }
    }
    
    func loadUser(_ username: String) {
        HypeMachineAPI.Requests.Users.show(username: username) { response in
            switch response.result {
            case .success(let user):
                self.user = user
            case .failure(let error):
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
                print(error)
            }
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
        
        Alamofire.request(user!.avatarURL!, method: .get)
            .validate()
            .responseImage
        { response in
            switch response.result {
            case .success(let image):
                self.avatarView.image = image
            case .failure(let error):
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
                print(error as NSError)
            }
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
        tracksViewController = TracksViewController(type: .loveCount, title: "", analyticsViewName: "User/Tracks")
        addChildViewController(tracksViewController)
        playlistContainer.addSubview(tracksViewController.view)
        tracksViewController.view.snp.makeConstraints { make in
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
    
    func followButtonClicked(_ sender: ActionButton) {
        HypeMachineAPI.Requests.Me.toggleUserFavorite(id: user!.username) { response in
            let favoritedState = sender.state == NSOnState
            
            switch response.result {
            case .success(let favorited):
                if favorited != favoritedState {
                    sender.state = favorited ? NSOnState : NSOffState
                }
            case .failure(let error):
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
                print(error)
                
                sender.state = sender.state == NSOffState ? NSOnState : NSOffState
            }
        }
    }
    
    // MARK: BaseContentViewController
    
    override func addLoaderView() {
        loaderViewController = LoaderViewController(size: .small)
        let insets = NSEdgeInsetsMake(0, 0, 1, 0)
        header.addSubview(loaderViewController!.view)
        loaderViewController!.view.snp.makeConstraints { make in
            make.edges.equalTo(self.header).inset(insets)
        }
    }
    
    override func refresh() {
        tracksViewController.refresh()
    }
    
    override var shouldShowStickyTrack: Bool {
        return false
    }
}
