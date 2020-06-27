import Cocoa
import SnapKit
import HypeMachineAPI

final class MainViewController: NSViewController,
	SidebarViewControllerDelegate,
	PopularSectionModeMenuTarget,
	FeedSectionModeMenuTarget,
	SearchSectionSortMenuTarget,
	FavoritesSectionPlaylistMenuTarget,
	LatestSectionModeMenuTarget {
	@IBOutlet private var mainContentView: NSView!

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
		view = NSView(frame: .zero)

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
		NavigationController.shared = navigationController
		addChild(navigationController)
		view.addSubview(navigationController.view)
		navigationController.view.snp.makeConstraints { make in
			make.top.equalTo(view)
			make.left.equalTo(sidebarViewController.view.snp.right)
			make.bottom.equalTo(view)
			make.right.equalTo(view)
		}

		let footerViewController = FooterViewController()
		addChild(footerViewController)
		view.addSubview(footerViewController.view)
		footerViewController.view.snp.makeConstraints { make in
			make.height.equalTo(47)
			make.left.equalTo(sidebarViewController.view.snp.right)
			make.bottom.equalTo(view)
			make.right.equalTo(view)
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

	@objc
	func displayError(_ notification: Notification) {
		let error = notification.userInfo!["error"] as! NSError
		let displayErrorViewController = DisplayErrorViewController(error: error)

		addChild(displayErrorViewController!)
		navigationController.contentView.addSubview((displayErrorViewController?.view)!)

		displayErrorViewController?.setupLayoutInSuperview()
		displayErrorViewController?.animateIn()

		displayErrorViewController?.animateOutWithDelay(4) {
			displayErrorViewController?.view.removeFromSuperview()
			displayErrorViewController?.removeFromParent()
		}
	}

	func updateUIForSection(_ section: NavigationSection) {
		let newViewController = section.viewControllerForTarget(self)
		currentViewController = newViewController
		navigationController.setViewControllers([newViewController], animated: false)
	}

	@objc
	func popularSectionModeChanged(_ sender: NSMenuItem) {
		let mode = PopularSectionMode(rawValue: sender.title)!
		let viewController = currentViewController as! TracksViewController
		viewController.dataSource = PopularTracksDataSource(viewController: viewController, mode: mode)
	}

	@objc
	func feedSectionModeChanged(_ sender: NSMenuItem) {
		let mode = FeedSectionMode(rawValue: sender.title)!
		let viewController = currentViewController as! TracksViewController
		viewController.dataSource = FeedTracksDataSource(viewController: viewController, mode: mode)
	}

	@objc
	func searchSectionSortChanged(_ sender: NSMenuItem) {
		let sort = SearchSectionSort(rawValue: sender.title)!
		let viewController = currentViewController as! SearchViewController
		viewController.sort = sort
	}

	@objc
	func favoritesSectionPlaylistChanged(_ sender: NSMenuItem) {
		let playlist = FavoritesSectionPlaylist(rawValue: sender.title)!
		let viewController = currentViewController as! TracksViewController
		viewController.dataSource = FavoriteTracksDataSource(viewController: viewController, playlist: playlist)
	}

	@objc
	func latestSectionModeChanged(_ sender: NSMenuItem) {
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
		savedViewController ?? createViewControllerForTarget(target)
	}

	var savedViewController: BaseContentViewController? {
		NavigationSection.viewControllers[title]
	}

	func createViewControllerForTarget(_ target: AnyObject?) -> BaseContentViewController {
		let targetViewController: BaseContentViewController

		switch self {
		case .popular:
			targetViewController = TracksViewController(type: .heatMap, title: title, analyticsViewName: analyticsViewName)!
		case .favorites:
			targetViewController = TracksViewController(type: .loveCount, title: title, analyticsViewName: analyticsViewName)!
			(targetViewController as! TracksViewController).showLoveButton = false
		case .latest:
			targetViewController = TracksViewController(type: .loveCount, title: title, analyticsViewName: analyticsViewName)!
		case .blogs:
			targetViewController = BlogsViewController(title: title, analyticsViewName: analyticsViewName)!
		case .feed:
			targetViewController = TracksViewController(type: .feed, title: title, analyticsViewName: analyticsViewName)!
		case .genres:
			targetViewController = TagsViewController(title: title, analyticsViewName: analyticsViewName)!
		case .friends:
			targetViewController = UsersViewController(title: title, analyticsViewName: analyticsViewName)!
		case .search:
			targetViewController = SearchViewController(title: title, analyticsViewName: analyticsViewName)!
		}

		if let dropdownMenu = menu(target) {
			targetViewController.navigationItem.titleView = NavigationItem.standardTitleDropdownButtonForMenu(dropdownMenu)
		}

		if let tracksViewController = targetViewController as? TracksViewController {
			switch self {
			case .popular:
				tracksViewController.dataSource = PopularTracksDataSource(viewController: tracksViewController, mode: .now)
			case .favorites:
				tracksViewController.dataSource = FavoriteTracksDataSource(viewController: tracksViewController, playlist: .all)
			case .latest:
				tracksViewController.dataSource = LatestTracksDataSource(viewController: tracksViewController, mode: .all)
			case .feed:
				tracksViewController.dataSource = FeedTracksDataSource(viewController: tracksViewController, mode: .all)
			default:
				break
			}
		}

		NavigationSection.viewControllers[title] = targetViewController

		return targetViewController
	}
}

extension PopularSectionMode {
	static func menu(_ target: AnyObject?) -> NSMenu {
		let menu = NSMenu()
		menu.title = navigationSection.title

		menu.addItem(withTitle: now.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: noRemixes.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: onlyRemixes.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: lastWeek.title, action: #selector(MainViewController.popularSectionModeChanged(_:)), keyEquivalent: "")

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
		menu.title = navigationSection.title

		menu.addItem(withTitle: all.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: one.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: two.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: three.title, action: #selector(MainViewController.favoritesSectionPlaylistChanged(_:)), keyEquivalent: "")

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
		menu.title = navigationSection.title

		menu.addItem(withTitle: all.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: freshest.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: noRemixes.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: onlyRemixes.title, action: #selector(MainViewController.latestSectionModeChanged(_:)), keyEquivalent: "")

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
		menu.title = navigationSection.title

		menu.addItem(withTitle: all.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: friends.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: blogs.title, action: #selector(MainViewController.feedSectionModeChanged(_:)), keyEquivalent: "")

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
		menu.title = navigationSection.title

		menu.addItem(withTitle: newest.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: mostFavorites.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")
		menu.addItem(withTitle: mostReblogged.title, action: #selector(MainViewController.searchSectionSortChanged(_:)), keyEquivalent: "")

		for item in menu.items {
			item.target = target
		}

		return menu
	}
}

protocol SearchSectionSortMenuTarget {
	func searchSectionSortChanged(_ sender: NSMenuItem)
}
