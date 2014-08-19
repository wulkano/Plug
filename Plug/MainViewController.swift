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
        
        changeNavigationSection(NavigationSection.Popular)
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
            if popularViewController!.dataSource == nil {
                setDataSourceForSection(section, viewController: popularViewController!)
            }
            return popularViewController!
        case .Favorites:
            favoritesViewController = (ensureViewController(favoritesViewController, identifier: "PlaylistViewController") as PlaylistViewController)
            if favoritesViewController!.dataSource == nil {
                setDataSourceForSection(section, viewController: favoritesViewController!)
            }
            return favoritesViewController!
        case .Latest:
            latestViewController = (ensureViewController(latestViewController, identifier: "PlaylistViewController") as PlaylistViewController)
            if latestViewController!.dataSource == nil {
                setDataSourceForSection(section, viewController: latestViewController!)
            }
            return latestViewController!
        case .Blogs:
            blogDirectoryViewController = (ensureViewController(blogDirectoryViewController, identifier: "BlogDirectoryViewController") as BlogDirectoryViewController)
            if blogDirectoryViewController!.dataSource == nil {
                setDataSourceForSection(section, viewController: blogDirectoryViewController!)
            }
            return blogDirectoryViewController!
        case .Feed:
            feedViewController = (ensureViewController(feedViewController, identifier: "FeedViewController") as PlaylistViewController)
            if feedViewController!.dataSource == nil {
                setDataSourceForSection(section, viewController: feedViewController!)
            }
            return feedViewController!
        case .Genres:
            genresViewController = (ensureViewController(genresViewController, identifier: "GenresViewController") as GenresViewController)
            if genresViewController!.dataSource == nil {
                setDataSourceForSection(section, viewController: genresViewController!)
            }
            return genresViewController!
        case .Friends:
            friendsViewController = (ensureViewController(friendsViewController, identifier: "FriendsViewController") as FriendsViewController)
            if self.friendsViewController!.dataSource == nil {
                setDataSourceForSection(section, viewController: friendsViewController!)
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
    
    func setDataSourceForSection(section: NavigationSection, viewController: NSViewController) {
        switch section {
        case .Popular:
            let dataSource = PopularPlaylistDataSource(playlistSubType: .Now)
            (viewController as PlaylistViewController).setDataSource(dataSource)
        case .Favorites:
            let dataSource = FavoritesPlaylistDataSource()
            (viewController as PlaylistViewController).setDataSource(dataSource)
        case .Latest:
            let dataSource = LatestPlaylistDataSource()
            (viewController as PlaylistViewController).setDataSource(dataSource)
        case .Blogs:
            let dataSource = BlogDirectoryDataSource()
            (viewController as BlogDirectoryViewController).setDataSource(dataSource)
        case .Feed:
            let dataSource = FeedPlaylistDataSource(playlistSubType: .All)
            (viewController as PlaylistViewController).setDataSource(dataSource)
        case .Genres:
            let dataSource = GenresDataSource()
            (viewController as GenresViewController).setDataSource(dataSource)
        case .Friends:
            let dataSource = FriendsDataSource()
            (viewController as FriendsViewController).setDataSource(dataSource)
        case .Search:
            "asdf"
        }
    }
}