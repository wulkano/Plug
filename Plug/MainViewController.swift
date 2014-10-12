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
    
    var navigationController: NavigationController!
    
    var popularViewController: PopularPlaylistViewController?
    var favoritesViewController: FavoritesPlaylistViewController?
    var latestViewController: LatestPlaylistViewController?
    var blogDirectoryViewController: BlogDirectoryViewController?
    var feedViewController: FeedPlaylistViewController?
    var genresViewController: GenresViewController?
    var friendsViewController: FriendsViewController?
    var searchViewController: SearchViewController?
    
    var currentViewController: NSViewController?
    
    var currentTrackViewController: NSViewController?
    
    var trafficButtons: TrafficButtons?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Notifications.Subscribe.NavigationSectionChanged(self, selector: "navigationSectionChanged:")
        Notifications.Subscribe.DisplayError(self, selector: "displayError:")
        Notifications.Subscribe.CurrentTrackDidShow(self, selector: "currentTrackDidShow:")
        Notifications.Subscribe.CurrentTrackDidHide(self, selector: "currentTrackDidHide:")
    }
    
    deinit {
        Notifications.Unsubscribe.All(self)
    }
    
    override func viewDidLoad() {
        for controller in childViewControllers {
            if controller is NavigationController {
                navigationController = controller as NavigationController
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidLoad()
        
        if currentViewController == nil {
            changeNavigationSection(NavigationSection.Popular)
        }
        
        addCurrentTrackViewController()
    }
    
    func changeNavigationSection(section: NavigationSection) {
        Notifications.Post.NavigationSectionChanged(section, sender: self)
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        let section = Notifications.Read.NavigationSectionNotification(notification)
        updateUIForSection(section)
    }
    
    func displayError(notification: NSNotification) {
        let error = Notifications.Read.ErrorNotification(notification)
        NSAlert(error: error).runModal()
    }
    
    func updateUIForSection(section: NavigationSection) {
        var newViewController = viewControllerForSection(section)
        navigationController.setNewRootViewController(newViewController)
    }
    
    func currentTrackDidShow(notification: NSNotification) {
        currentTrackViewController!.view.hidden = true
    }

    func currentTrackDidHide(notification: NSNotification) {
        currentTrackViewController!.view.hidden = false
    }
    
    func addCurrentTrackViewController() {
        currentTrackViewController = storyboard!.instantiateControllerWithIdentifier("CurrentlyPlaylingTrackViewController") as CurrentlyPlaylingTrackViewController
        let insets = NSEdgeInsetsMake(0, 69, 47, 0)
        ViewPlacementHelper.AddBottomAnchoredSubview(currentTrackViewController!.view, toSuperView: view, withFixedHeight: 70, andInsets: insets)
        currentTrackViewController!.view.hidden = true
    }
    
    func viewControllerForSection(section: NavigationSection) -> BaseContentViewController {
        
//        TODO: This sucks I hate it
        var newViewController: NSViewController
        
        switch section {
        case .Popular:
            popularViewController = (ensureViewController(popularViewController, identifier: "PopularPlaylistViewController") as PopularPlaylistViewController)
            return popularViewController!
        case .Favorites:
            favoritesViewController = (ensureViewController(favoritesViewController, identifier: "FavoritesPlaylistViewController") as FavoritesPlaylistViewController)
            return favoritesViewController!
        case .Latest:
            latestViewController = (ensureViewController(latestViewController, identifier: "LatestPlaylistViewController") as LatestPlaylistViewController)
            return latestViewController!
        case .Blogs:
            blogDirectoryViewController = (ensureViewController(blogDirectoryViewController, identifier: "BlogDirectoryViewController") as BlogDirectoryViewController)
            return blogDirectoryViewController!
        case .Feed:
            feedViewController = (ensureViewController(feedViewController, identifier: "FeedPlaylistViewController") as FeedPlaylistViewController)
            return feedViewController!
        case .Genres:
            genresViewController = (ensureViewController(genresViewController, identifier: "GenresViewController") as GenresViewController)
            return genresViewController!
        case .Friends:
            friendsViewController = (ensureViewController(friendsViewController, identifier: "FriendsViewController") as FriendsViewController)
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
            let newController = storyboard!.instantiateControllerWithIdentifier(identifier) as NSViewController
            addChildViewController(newController)
            return newController
        }
    }
    
    func transitionMainContentViewController(controller: NSViewController) {
        if currentViewController == nil { return }
        
        let transitions = NSViewControllerTransitionOptions.Crossfade | NSViewControllerTransitionOptions.SlideLeft
        transitionFromViewController(currentViewController!, toViewController: controller, options: transitions, completionHandler:  {
            for subview in self.mainContentView.subviews {
                if subview !== controller.view {
                    (subview as NSView).removeFromSuperview()
                }
            }
        })
    }
}
