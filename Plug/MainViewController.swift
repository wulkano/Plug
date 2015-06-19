//
//  MainViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, PopularSectionModeMenuTarget, FeedSectionModeMenuTarget, SearchSectionSortMenuTarget {
    @IBOutlet weak var mainContentView: NSView!
    
    var navigationController: NavigationController!
    var currentViewController: BaseContentViewController!
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
        let insets = NSEdgeInsetsMake(0,0, 0, 0)
        ViewPlacementHelper.addTopAnchoredSubview(displayErrorViewController.view, toSuperView: navigationController.contentView, withFixedHeight: 40, andInsets: insets)
        Interval.single(5) {
            displayErrorViewController.view.removeFromSuperview()
            displayErrorViewController.removeFromParentViewController()
        }
    }
    
    func updateUIForSection(section: NavigationSection) {
        var newViewController = section.viewController(storyboard!, target: self)
        currentViewController = newViewController
        navigationController.setNewRootViewController(newViewController)
    }
    
    func popularSectionModeChanged(sender: NSMenuItem) {
        let mode = PopularSectionMode(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = PopularTracksDataSource(viewController: viewController, mode: mode)
    }
    
    func feedSectionModeChanged(sender: NSMenuItem) {
        let mode = FeedSectionMode(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = FeedTracksDataSource(viewController: viewController, mode: mode)
    }
    
    func searchSectionSortChanged(sender: NSMenuItem) {
        let sort = SearchSectionSort(rawValue: sender.title)!
        let viewController = currentViewController as! SearchViewController
        viewController.sort = sort
    }
}

extension NavigationSection {
    static var viewControllers = [String: BaseContentViewController]()
    
    var viewControllerIdentifier: String {
        switch self {
        case .Popular:
            return "PopularTracksViewController"
        case .Favorites:
            return "FavoriteTracksViewController"
        case .Latest:
            return "LatestTracksViewController"
        case .Blogs:
            return "BlogDirectoryViewController"
        case .Feed:
            return "FeedTracksViewController"
        case .Genres:
            return "TagsViewController"
        case .Friends:
            return "FriendsViewController"
        case .Search:
            return "SearchViewController"
        }
    }
    
    func menu(target: AnyObject?) -> NSMenu? {
        switch self {
        case .Popular:
            return PopularSectionMode.menu(target)
        case .Feed:
            return FeedSectionMode.menu(target)
        case .Search:
            return SearchSectionSort.menu(target)
        default:
            return nil
        }
    }
    
    func viewController(storyboard: NSStoryboard, target: AnyObject?) -> BaseContentViewController {
        return savedViewController ?? createViewController(storyboard, target: target)
    }
    
    private var savedViewController: BaseContentViewController? {
        return NavigationSection.viewControllers[self.viewControllerIdentifier]
    }
    
    private func createViewController(storyboard: NSStoryboard, target: AnyObject?) -> BaseContentViewController {
        let targetViewController = storyboard.instantiateControllerWithIdentifier(self.viewControllerIdentifier) as! BaseContentViewController
        targetViewController.dropdownMenu = self.menu(target)

        if let tracksViewController = targetViewController as? TracksViewController {
            switch self {
            case .Popular:
                tracksViewController.dataSource = PopularTracksDataSource(viewController: tracksViewController, mode: .Now)
            case .Favorites:
                tracksViewController.dataSource = FavoriteTracksDataSource(viewController: tracksViewController)
            case .Latest:
                tracksViewController.dataSource = LatestTracksDataSource(viewController: tracksViewController)
            case .Feed:
                tracksViewController.dataSource = FeedTracksDataSource(viewController: tracksViewController, mode: .All)
            default:
                break
            }
        }
        
        NavigationSection.viewControllers[self.viewControllerIdentifier] = targetViewController
        
        return targetViewController
    }
}

extension PopularSectionMode {
    static func menu(target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItemWithTitle(self.Now.title, action: "popularSectionModeChanged:", keyEquivalent: "")
        menu.addItemWithTitle(self.NoRemixes.title, action: "popularSectionModeChanged:", keyEquivalent: "")
        menu.addItemWithTitle(self.OnlyRemixes.title, action: "popularSectionModeChanged:", keyEquivalent: "")
        menu.addItemWithTitle(self.LastWeek.title, action: "popularSectionModeChanged:", keyEquivalent: "")
        
        for item in (menu.itemArray as! [NSMenuItem]) {
            item.target = target
        }
        
        return menu
    }
}

protocol PopularSectionModeMenuTarget {
    func popularSectionModeChanged(sender: NSMenuItem)
}

extension FeedSectionMode {
    static func menu(target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItemWithTitle(self.All.title, action: "feedSectionModeChanged:", keyEquivalent: "")
        menu.addItemWithTitle(self.Friends.title, action: "feedSectionModeChanged:", keyEquivalent: "")
        menu.addItemWithTitle(self.Blogs.title, action: "feedSectionModeChanged:", keyEquivalent: "")
        
        for item in (menu.itemArray as! [NSMenuItem]) {
            item.target = target
        }
        
        return menu
    }
}

protocol FeedSectionModeMenuTarget {
    func feedSectionModeChanged(sender: NSMenuItem)
}

extension SearchSectionSort {
    static func menu(target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItemWithTitle(self.Newest.title, action: "searchSectionSortChanged:", keyEquivalent: "")
        menu.addItemWithTitle(self.MostFavorites.title, action: "searchSectionSortChanged:", keyEquivalent: "")
        menu.addItemWithTitle(self.MostReblogged.title, action: "searchSectionSortChanged:", keyEquivalent: "")
        
        for item in (menu.itemArray as! [NSMenuItem]) {
            item.target = target
        }
        
        return menu
    }
}

protocol SearchSectionSortMenuTarget {
    func searchSectionSortChanged(sender: NSMenuItem)
}