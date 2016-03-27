//
//  MainViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import SnapKit
import HypeMachineAPI

class MainViewController: NSViewController, SidebarViewControllerDelegate, PopularSectionModeMenuTarget, FeedSectionModeMenuTarget, SearchSectionSortMenuTarget, FavoritesSectionPlaylistMenuTarget, LatestSectionModeMenuTarget {
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
        Notifications.subscribe(observer: self, selector: #selector(displayError), name: Notifications.DisplayError, object: nil)
    }
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        let sidebarViewController = SidebarViewController(delegate: self)!
        addChildViewController(sidebarViewController)
        view.addSubview(sidebarViewController.view)
        sidebarViewController.view.snp_makeConstraints { make in
            make.width.equalTo(69)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        navigationController = NavigationController(rootViewController: nil)
        NavigationController.sharedInstance = navigationController
        addChildViewController(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.snp_makeConstraints { make in
            make.top.equalTo(self.view)
            make.left.equalTo(sidebarViewController.view.snp_right)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        let footerViewController = FooterViewController()
        addChildViewController(footerViewController)
        view.addSubview(footerViewController.view)
        footerViewController.view.snp_makeConstraints { make in
            make.height.equalTo(47)
            make.left.equalTo(sidebarViewController.view.snp_right)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        if currentViewController == nil {
            changeNavigationSection(NavigationSection.Popular)
        }
    }
    
    func changeNavigationSection(section: NavigationSection) {
        updateUIForSection(section)
    }
    
    func displayError(notification: NSNotification) {
        let error = notification.userInfo!["error"] as! NSError
        let displayErrorViewController = DisplayErrorViewController(error: error)
        
        addChildViewController(displayErrorViewController)
        navigationController.contentView.addSubview(displayErrorViewController.view)
        
        displayErrorViewController.setupLayoutInSuperview()
        displayErrorViewController.animateIn()
        displayErrorViewController.animateOutWithDelay(4, completionHandler: {
            displayErrorViewController.view.removeFromSuperview()
            displayErrorViewController.removeFromParentViewController()
        })
    }
    
    func updateUIForSection(section: NavigationSection) {
        let newViewController = section.viewControllerForTarget(self)
        currentViewController = newViewController
        navigationController.setViewControllers([newViewController], animated: false)
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
    
    func favoritesSectionPlaylistChanged(sender: NSMenuItem) {
        let playlist = FavoritesSectionPlaylist(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = FavoriteTracksDataSource(viewController: viewController, playlist: playlist)
    }
    
    func latestSectionModeChanged(sender: NSMenuItem) {
        let mode = LatestSectionMode(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = LatestTracksDataSource(viewController: viewController, mode: mode)
    }
}

extension NavigationSection {
    static var viewControllers = [String: BaseContentViewController]()
    
    func menu(target: AnyObject?) -> NSMenu? {
        switch self {
        case .Popular:
            return PopularSectionMode.menu(target)
        case .Favorites:
            return FavoritesSectionPlaylist.menu(target)
        case .Latest:
            return LatestSectionMode.menu(target)
        case .Feed:
            return FeedSectionMode.menu(target)
        case .Search:
            return SearchSectionSort.menu(target)
        default:
            return nil
        }
    }
    
    func viewControllerForTarget(target: AnyObject?) -> BaseContentViewController {
        return savedViewController ?? createViewControllerForTarget(target)
    }
    
    var savedViewController: BaseContentViewController? {
        return NavigationSection.viewControllers[self.title]
    }
    
    func createViewControllerForTarget(target: AnyObject?) -> BaseContentViewController {
        
        var targetViewController: BaseContentViewController
        
        switch self {
        case .Popular:
            targetViewController = TracksViewController(type: .HeatMap, title: self.title, analyticsViewName: self.analyticsViewName)!
        case .Favorites:
            targetViewController = TracksViewController(type: .LoveCount, title: self.title, analyticsViewName: self.analyticsViewName)!
            (targetViewController as! TracksViewController).showLoveButton = false
        case .Latest:
            targetViewController = TracksViewController(type: .LoveCount, title: self.title, analyticsViewName: self.analyticsViewName)!
        case .Blogs:
            targetViewController = BlogsViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        case .Feed:
            targetViewController = TracksViewController(type: .Feed, title: self.title, analyticsViewName: self.analyticsViewName)!
        case .Genres:
            targetViewController = TagsViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        case .Friends:
            targetViewController = UsersViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        case .Search:
            targetViewController = SearchViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        }
        
        if let dropdownMenu = self.menu(target) {
            targetViewController.navigationItem.titleView = NavigationItem.standardTitleDropdownButtonForMenu(dropdownMenu)
        }

        if let tracksViewController = targetViewController as? TracksViewController {
            switch self {
            case .Popular:
                tracksViewController.dataSource = PopularTracksDataSource(viewController: tracksViewController, mode: .Now)
            case .Favorites:
                tracksViewController.dataSource = FavoriteTracksDataSource(viewController: tracksViewController, playlist: .All)
            case .Latest:
                tracksViewController.dataSource = LatestTracksDataSource(viewController: tracksViewController, mode: .All)
            case .Feed:
                tracksViewController.dataSource = FeedTracksDataSource(viewController: tracksViewController, mode: .All)
            default:
                break
            }
        }
        
        NavigationSection.viewControllers[self.title] = targetViewController
        
        return targetViewController
    }
}

extension PopularSectionMode {
    static func menu(target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItemWithTitle(self.Now.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.NoRemixes.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.OnlyRemixes.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.LastWeek.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        
        for item in menu.itemArray {
            item.target = target
        }
        
        return menu
    }
}

protocol PopularSectionModeMenuTarget {
    func popularSectionModeChanged(sender: NSMenuItem)
}

extension FavoritesSectionPlaylist {
    static func menu(target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItemWithTitle(self.All.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.One.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.Two.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.Three.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        
        for item in menu.itemArray {
            item.target = target
        }
        
        return menu
    }
}

protocol FavoritesSectionPlaylistMenuTarget {
    func favoritesSectionPlaylistChanged(sender: NSMenuItem)
}

extension LatestSectionMode {
    static func menu(target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItemWithTitle(self.All.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.Freshest.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.NoRemixes.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.OnlyRemixes.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        
        for item in menu.itemArray {
            item.target = target
        }
        
        return menu
    }
}

protocol LatestSectionModeMenuTarget {
    func latestSectionModeChanged(sender: NSMenuItem)
}

extension FeedSectionMode {
    static func menu(target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItemWithTitle(self.All.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.Friends.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.Blogs.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
        
        for item in menu.itemArray {
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
        
        menu.addItemWithTitle(self.Newest.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.MostFavorites.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
        menu.addItemWithTitle(self.MostReblogged.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
        
        for item in menu.itemArray {
            item.target = target
        }
        
        return menu
    }
}

protocol SearchSectionSortMenuTarget {
    func searchSectionSortChanged(sender: NSMenuItem)
}