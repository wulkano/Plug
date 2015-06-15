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
    
    var popularViewController: TracksViewController?
    var favoritesViewController: TracksViewController?
    var latestViewController: TracksViewController?
    var blogDirectoryViewController: BlogDirectoryViewController?
    var feedViewController: TracksViewController?
    var tagsViewController: TagsViewController?
    var friendsViewController: FriendsViewController?
    var searchViewController: SearchViewController?
    
    var currentViewController: BaseContentViewController!
    
    var currentTrackViewController: NSViewController?
    
    var trafficButtons: TrafficButtons?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    func setup() {
        Notifications.subscribe(observer: self, selector: "navigationSectionChanged:", name: Notifications.NavigationSectionChanged, object: nil)
        Notifications.subscribe(observer: self, selector: "displayError:", name: Notifications.DisplayError, object: nil)
        Notifications.subscribe(observer: self, selector: "currentTrackDidShow:", name: Notifications.CurrentTrackDidShow, object: nil)
        Notifications.subscribe(observer: self, selector: "currentTrackDidHide:", name: Notifications.CurrentTrackDidHide, object: nil)
    }
    
    override func viewDidLoad() {
        for controller in childViewControllers {
            if controller is NavigationController {
                navigationController = controller as! NavigationController
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidLoad()
        
        if currentViewController == nil {
            changeNavigationSection(NavigationSection.Popular)
        }
        
        addCurrentTrackViewController()
//        Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": NSError()])
    }
    
    func changeNavigationSection(section: NavigationSection) {
        Notifications.post(name: Notifications.NavigationSectionChanged, object: self, userInfo: ["navigationSection": section.rawValue])
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        let raw = (notification.userInfo!["navigationSection"] as! NSNumber).integerValue
        let section = NavigationSection(rawValue: raw)!
        updateUIForSection(section)
    }
    
    func displayError(notification: NSNotification) {
        let error = notification.userInfo!["error"] as! NSError
        let displayErrorViewController = storyboard!.instantiateControllerWithIdentifier("DisplayErrorViewController") as! DisplayErrorViewController
        displayErrorViewController.representedObject = error
        let insets = NSEdgeInsetsMake(36, 69, 0, 0)
        ViewPlacementHelper.AddTopAnchoredSubview(displayErrorViewController.view, toSuperView: view, withFixedHeight: 40, andInsets: insets)
        Interval.single(5, closure: {
            displayErrorViewController.view.removeFromSuperview()
        })
    }
    
    func updateUIForSection(section: NavigationSection) {
        var newViewController = viewControllerForSection(section)
        currentViewController = newViewController
        navigationController.setNewRootViewController(newViewController)
    }
    
    func currentTrackDidShow(notification: NSNotification) {
        currentTrackViewController!.view.hidden = true
    }

    func currentTrackDidHide(notification: NSNotification) {
        currentTrackViewController!.view.hidden = false
    }
    
    func addCurrentTrackViewController() {
        currentTrackViewController = storyboard!.instantiateControllerWithIdentifier("CurrentlyPlaylingTrackViewController") as! CurrentlyPlaylingTrackViewController
        let insets = NSEdgeInsetsMake(0, 69, 47, 0)
        ViewPlacementHelper.AddBottomAnchoredSubview(currentTrackViewController!.view, toSuperView: view, withFixedHeight: 70, andInsets: insets)
        currentTrackViewController!.view.hidden = true
    }
    
    func viewControllerForSection(section: NavigationSection) -> BaseContentViewController {
        
//        TODO: This sucks I hate it
        var newViewController: NSViewController
        
        switch section {
        case .Popular:
            popularViewController = (ensureViewController(popularViewController, identifier: "PopularTracksViewController") as! TracksViewController)
            let menu = NSMenu(title: "Popular")
            menu.addItemWithTitle("Now", action: "", keyEquivalent: "")
            menu.addItemWithTitle("Last Week", action: "", keyEquivalent: "")
            menu.addItemWithTitle("No Remixes", action: "", keyEquivalent: "")
            menu.addItemWithTitle("Remixes Only", action: "", keyEquivalent: "")
            popularViewController!.dropdownMenu = menu
            return popularViewController!
        case .Favorites:
            favoritesViewController = (ensureViewController(favoritesViewController, identifier: "FavoriteTracksViewController") as! TracksViewController)
            return favoritesViewController!
        case .Latest:
            latestViewController = (ensureViewController(latestViewController, identifier: "LatestTracksViewController") as! TracksViewController)
            return latestViewController!
        case .Blogs:
            blogDirectoryViewController = (ensureViewController(blogDirectoryViewController, identifier: "BlogDirectoryViewController") as! BlogDirectoryViewController)
            return blogDirectoryViewController!
        case .Feed:
            feedViewController = (ensureViewController(feedViewController, identifier: "FeedTracksViewController") as! TracksViewController)
            return feedViewController!
        case .Genres:
            tagsViewController = (ensureViewController(tagsViewController, identifier: "TagsViewController") as! TagsViewController)
            return tagsViewController!
        case .Friends:
            friendsViewController = (ensureViewController(friendsViewController, identifier: "FriendsViewController") as! FriendsViewController)
            return friendsViewController!
        case .Search:
            searchViewController = (ensureViewController(searchViewController, identifier: "SearchViewController") as! SearchViewController)
            return searchViewController!
        }
    }
    
    func ensureViewController(controller: NSViewController?, identifier: String) -> NSViewController {
        if controller != nil {
            return controller!
        } else {
            let newController = storyboard!.instantiateControllerWithIdentifier(identifier) as! NSViewController
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
                    (subview as! NSView).removeFromSuperview()
                }
            }
        })
    }
}
