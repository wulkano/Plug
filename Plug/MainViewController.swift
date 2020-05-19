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

class MainViewController:
    NSViewController,
    SidebarViewControllerDelegate,
    PopularSectionModeMenuTarget,
    FeedSectionModeMenuTarget,
    SearchSectionSortMenuTarget,
    FavoritesSectionPlaylistMenuTarget,
    LatestSectionModeMenuTarget
{
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
		addChild(sidebarViewController)
        view.addSubview(sidebarViewController.view)
        sidebarViewController.view.snp.makeConstraints { make in
            make.width.equalTo(69)
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        navigationController = NavigationController(rootViewController: nil)
        NavigationController.sharedInstance = navigationController
		addChild(navigationController)
        view.addSubview(navigationController.view)
        navigationController.view.snp.makeConstraints { make in
            make.top.equalTo(self.view)
            make.left.equalTo(sidebarViewController.view.snp.right)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        let footerViewController = FooterViewController()
		addChild(footerViewController)
        view.addSubview(footerViewController.view)
        footerViewController.view.snp.makeConstraints { make in
            make.height.equalTo(47)
            make.left.equalTo(sidebarViewController.view.snp.right)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        
        if currentViewController == nil {
            changeNavigationSection(NavigationSection.popular)
        }
    }
    
    func changeNavigationSection(_ section: NavigationSection) {
        updateUIForSection(section)
    }
    
	@objc func displayError(_ notification: Notification) {
        let error = (notification as NSNotification).userInfo!["error"] as! NSError
        let displayErrorViewController = DisplayErrorViewController(error: error)
        
		addChild(displayErrorViewController!)
        navigationController.contentView.addSubview((displayErrorViewController?.view)!)
        
        displayErrorViewController?.setupLayoutInSuperview()
        displayErrorViewController?.animateIn()
        displayErrorViewController?.animateOutWithDelay(4, completionHandler: {
            displayErrorViewController?.view.removeFromSuperview()
			displayErrorViewController?.removeFromParent()
        })
    }
    
    func updateUIForSection(_ section: NavigationSection) {
        let newViewController = section.viewControllerForTarget(self)
        currentViewController = newViewController
        navigationController.setViewControllers([newViewController], animated: false)
    }
    
	@objc func popularSectionModeChanged(_ sender: NSMenuItem) {
        let mode = PopularSectionMode(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = PopularTracksDataSource(viewController: viewController, mode: mode)
    }
    
	@objc func feedSectionModeChanged(_ sender: NSMenuItem) {
        let mode = FeedSectionMode(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = FeedTracksDataSource(viewController: viewController, mode: mode)
    }
    
	@objc func searchSectionSortChanged(_ sender: NSMenuItem) {
        let sort = SearchSectionSort(rawValue: sender.title)!
        let viewController = currentViewController as! SearchViewController
        viewController.sort = sort
    }
    
	@objc func favoritesSectionPlaylistChanged(_ sender: NSMenuItem) {
        let playlist = FavoritesSectionPlaylist(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = FavoriteTracksDataSource(viewController: viewController, playlist: playlist)
    }
    
	@objc func latestSectionModeChanged(_ sender: NSMenuItem) {
        let mode = LatestSectionMode(rawValue: sender.title)!
        let viewController = currentViewController as! TracksViewController
        viewController.dataSource = LatestTracksDataSource(viewController: viewController, mode: mode)
    }
}

extension NavigationSection {
    static var viewControllers = [String: BaseContentViewController]()
    
    func menu(_ target: AnyObject?) -> NSMenu? {
        switch self {
        case .popular:
            return PopularSectionMode.menu(target)
        case .favorites:
            return FavoritesSectionPlaylist.menu(target)
        case .latest:
            return LatestSectionMode.menu(target)
        case .feed:
            return FeedSectionMode.menu(target)
        case .search:
            return SearchSectionSort.menu(target)
        default:
            return nil
        }
    }
    
    func viewControllerForTarget(_ target: AnyObject?) -> BaseContentViewController {
        return savedViewController ?? createViewControllerForTarget(target)
    }
    
    var savedViewController: BaseContentViewController? {
        return NavigationSection.viewControllers[self.title]
    }
    
    func createViewControllerForTarget(_ target: AnyObject?) -> BaseContentViewController {
        
        var targetViewController: BaseContentViewController
        
        switch self {
        case .popular:
            targetViewController = TracksViewController(type: .heatMap, title: self.title, analyticsViewName: self.analyticsViewName)!
        case .favorites:
            targetViewController = TracksViewController(type: .loveCount, title: self.title, analyticsViewName: self.analyticsViewName)!
            (targetViewController as! TracksViewController).showLoveButton = false
        case .latest:
            targetViewController = TracksViewController(type: .loveCount, title: self.title, analyticsViewName: self.analyticsViewName)!
        case .blogs:
            targetViewController = BlogsViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        case .feed:
            targetViewController = TracksViewController(type: .feed, title: self.title, analyticsViewName: self.analyticsViewName)!
        case .genres:
            targetViewController = TagsViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        case .friends:
            targetViewController = UsersViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        case .search:
            targetViewController = SearchViewController(title: self.title, analyticsViewName: self.analyticsViewName)!
        }
        
        if let dropdownMenu = self.menu(target) {
            targetViewController.navigationItem.titleView = NavigationItem.standardTitleDropdownButtonForMenu(dropdownMenu)
        }

        if let tracksViewController = targetViewController as? TracksViewController {
            switch self {
            case .popular:
                tracksViewController.dataSource = PopularTracksDataSource(viewController: tracksViewController, mode: .Now)
            case .favorites:
                tracksViewController.dataSource = FavoriteTracksDataSource(viewController: tracksViewController, playlist: .All)
            case .latest:
                tracksViewController.dataSource = LatestTracksDataSource(viewController: tracksViewController, mode: .All)
            case .feed:
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
    static func menu(_ target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItem(withTitle: self.Now.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.NoRemixes.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.OnlyRemixes.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.LastWeek.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
        
        for item in menu.items {
            item.target = target
        }
        
        return menu
    }
}

protocol PopularSectionModeMenuTarget {
    func popularSectionModeChanged(_ sender: NSMenuItem)
}

extension FavoritesSectionPlaylist {
    static func menu(_ target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItem(withTitle: self.All.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.One.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.Two.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.Three.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
        
        for item in menu.items {
            item.target = target
        }
        
        return menu
    }
}

protocol FavoritesSectionPlaylistMenuTarget {
    func favoritesSectionPlaylistChanged(_ sender: NSMenuItem)
}

extension LatestSectionMode {
    static func menu(_ target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItem(withTitle: self.All.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.Freshest.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.NoRemixes.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.OnlyRemixes.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
        
        for item in menu.items {
            item.target = target
        }
        
        return menu
    }
}

protocol LatestSectionModeMenuTarget {
    func latestSectionModeChanged(_ sender: NSMenuItem)
}

extension FeedSectionMode {
    static func menu(_ target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItem(withTitle: self.All.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.Friends.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.Blogs.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
        
        for item in menu.items {
            item.target = target
        }
        
        return menu
    }
}

protocol FeedSectionModeMenuTarget {
    func feedSectionModeChanged(_ sender: NSMenuItem)
}

extension SearchSectionSort {
    static func menu(_ target: AnyObject?) -> NSMenu {
        let menu = NSMenu()
        menu.title = self.navigationSection.title
        
        menu.addItem(withTitle: self.Newest.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.MostFavorites.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
        menu.addItem(withTitle: self.MostReblogged.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
        
        for item in menu.items {
            item.target = target
        }
        
        return menu
    }
}

protocol SearchSectionSortMenuTarget {
    func searchSectionSortChanged(_ sender: NSMenuItem)
}
