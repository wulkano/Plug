//
//  MainViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    @IBOutlet weak var mainContentView: NSView!
    
    var popularViewController: PlaylistViewController?
    var favoritesViewController: PlaylistViewController?
    var latestViewController: PlaylistViewController?
    var blogDirectoryViewController: BlogDirectoryViewController?
    var feedViewController: PlaylistViewController?
    var genresViewController: GenresViewController?
    var friendsViewController: FriendsViewController?
    var searchViewController: SearchViewController?
    var currentViewController: NSViewController?
    
    required init(coder: NSCoder!) {
        super.init(coder: coder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "navigationSectionChanged:", name: Notifications.NavigationSectionChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayError:", name: Notifications.Error, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Remove
        if mainContentView {
            changeNavigationSection(NavigationSection.Popular)
        }
    }
    
    override func viewDidAppear() {
    }
    
    func changeNavigationSection(section: NavigationSection) {
        NavigationSection.postChangeNotification(section, object: self)
        updateUIForSection(section)
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        if notification.object === self { return }
        let section = NavigationSection.fromNotification(notification)
        updateUIForSection(section)
    }
    
    func displayError(notification: NSNotification) {
//        TODO: Fancy error display
        let error = AppError.fromNotification(notification)
        AppError.logError(error)
    }
    
    func updateUIForSection(section: NavigationSection) {
        var newViewController = viewControllerForSection(section)
        setMainContentSubview(newViewController.view)
        transitionMainContentViewController(newViewController)
        currentViewController = newViewController
    }
    
    func viewControllerForSection(section: NavigationSection) -> NSViewController {
        
//        TODO: This sucks I hate it
        var newViewController: NSViewController
        
        switch section {
        case .Popular:
            popularViewController = (ensureViewController(popularViewController, identifier: "PlaylistViewController") as PlaylistViewController)
            if popularViewController!.playlist == nil {
                setTableContentsForSection(section)
//                self.popularViewController!.playlist = Playlist.mockPlaylist(20)
            }
            return popularViewController!
        case .Favorites:
            favoritesViewController = (ensureViewController(favoritesViewController, identifier: "PlaylistViewController") as PlaylistViewController)
            if favoritesViewController!.playlist == nil {
                self.favoritesViewController!.playlist = Playlist.mockPlaylist(20)
            }
            return favoritesViewController!
        case .Latest:
            latestViewController = (ensureViewController(latestViewController, identifier: "PlaylistViewController") as PlaylistViewController)
            if latestViewController!.playlist == nil {
                self.latestViewController!.playlist = Playlist.mockPlaylist(20)
            }
            return latestViewController!
        case .Blogs:
            blogDirectoryViewController = (ensureViewController(blogDirectoryViewController, identifier: "BlogDirectoryViewController") as BlogDirectoryViewController)
            if blogDirectoryViewController!.tableContents.count == 0 {
                var blogStuff = [BlogDirectoryItem]()
                blogStuff.append(BlogDirectoryItem.SectionHeaderItem(SectionHeader(title: "Following")))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.SectionHeaderItem(SectionHeader(title: "Featured")))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogStuff.append(BlogDirectoryItem.BlogItem(Blog()))
                blogDirectoryViewController!.tableContents = blogStuff
            }
            return blogDirectoryViewController!
        case .Feed:
            feedViewController = (ensureViewController(feedViewController, identifier: "FeedViewController") as PlaylistViewController)
            if feedViewController!.playlist == nil {
                self.feedViewController!.playlist = Playlist.mockPlaylist(20)
            }
            return feedViewController!
        case .Genres:
            genresViewController = (ensureViewController(genresViewController, identifier: "GenresViewController") as GenresViewController)
            if self.genresViewController!.tableContents.count == 0 {
                var genresStuff = [GenresListItem]()
                genresStuff.append(GenresListItem.SectionHeaderItem(SectionHeader(title: "The Basics")))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.SectionHeaderItem(SectionHeader(title: "Everything")))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresStuff.append(GenresListItem.GenreItem(Genre(JSON: ["tag_name": "Genre Name"])))
                genresViewController!.tableContents = genresStuff
            }
            return genresViewController!
        case .Friends:
            friendsViewController = (ensureViewController(friendsViewController, identifier: "FriendsViewController") as FriendsViewController)
            if self.friendsViewController!.tableContents.count == 0 {
                var friends = [Friend]()
                friends.append(Friend())
                friends.append(Friend())
                friends.append(Friend())
                friends.append(Friend())
                friends.append(Friend())
                friends.append(Friend())
                friends.append(Friend())
                friendsViewController!.tableContents = friends
            }
            return friendsViewController!
        case .Search:
            searchViewController = (ensureViewController(searchViewController, identifier: "SearchViewController") as SearchViewController)
            return searchViewController!
        }
    }
    
    func ensureViewController(controller: NSViewController?, identifier: String) -> NSViewController {
        if controller != nil {
            return controller!
        } else {
             let newController = storyboard.instantiateControllerWithIdentifier(identifier) as NSViewController
            addChildViewController(newController)
            return newController
        }
    }
    
    func setMainContentSubview(view: NSView) {
        view.frame = mainContentView.bounds
        view.translatesAutoresizingMaskIntoConstraints = false
        mainContentView.addSubview(view)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view": view])
        mainContentView.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view": view])
        mainContentView.addConstraints(constraints)
    }
    
    func transitionMainContentViewController(controller: NSViewController) {
        if currentViewController != nil {
            transitionFromViewController(currentViewController, toViewController: controller, options: NSViewControllerTransitionOptions.SlideLeft | NSViewControllerTransitionOptions.Crossfade, completionHandler:  {
                for subview in self.mainContentView.subviews {
                    if subview !== controller.view {
                        (subview as NSView).removeFromSuperview()
                    }
                }
            })
        }
    }
    
    func setTableContentsForSection(section: NavigationSection) {
        switch section {
        case .Popular:
            HypeMachineAPI.Playlists.Popular(PopularPlaylistSubType.Now,
                success: {playlist in
                    self.popularViewController!.playlist = playlist
                    println(self.popularViewController!.playlist!.tracks)
                    self.popularViewController!.tableView.reloadData()
                }, failure: {error in
                    AppError.logError(error)
            })
        case .Favorites, .Latest, .Blogs, .Feed, .Genres, .Friends, .Search:
            "asdf"
        }
    }
}
