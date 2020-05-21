import Cocoa

final class SearchViewController: BaseContentViewController {
	var searchResultsView: NSView!

	var sort: SearchSectionSort = .Newest {
		didSet { sortChanged() }
	}

	var tracksViewController: TracksViewController?
	var dataSource: TracksDataSource?

	@objc
	func searchFieldSubmit(_ sender: NSSearchField) {
		let keywords = sender.stringValue

		guard !keywords.isEmpty else {
			return
		}

		ensurePlaylistViewController()
		tracksViewController!.dataSource = SearchTracksDataSource(viewController: tracksViewController!, sort: sort, searchQuery: keywords)
	}

	func ensurePlaylistViewController() {
		if tracksViewController == nil {
			tracksViewController = TracksViewController(type: .loveCount, title: "", analyticsViewName: "Search/Tracks")
			addChild(tracksViewController!)
			searchResultsView.addSubview(tracksViewController!.view)
			tracksViewController!.view.snp.makeConstraints { make in
				make.edges.equalTo(searchResultsView)
			}
		}
	}

	func sortChanged() {
		guard
			tracksViewController != nil,
			tracksViewController!.dataSource != nil
		else {
			return
		}

		let searchDataSource = tracksViewController!.dataSource! as! SearchTracksDataSource
		tracksViewController!.dataSource = SearchTracksDataSource(viewController: tracksViewController!, sort: sort, searchQuery: searchDataSource.searchQuery)
	}

	// MARK: NSView

	override func loadView() {
		super.loadView()

		let searchHeaderController = SearchHeaderViewController(nibName: nil, bundle: nil)
		view.addSubview(searchHeaderController.view)
		searchHeaderController.view.snp.makeConstraints { make in
			make.height.equalTo(52)
			make.top.equalTo(self.view)
			make.left.equalTo(self.view)
			make.right.equalTo(self.view)
		}
		searchHeaderController.searchField.target = self
		searchHeaderController.searchField.action = #selector(SearchViewController.searchFieldSubmit(_:))

		searchResultsView = NSView()
		view.addSubview(searchResultsView)
		searchResultsView.snp.makeConstraints { make in
			make.top.equalTo(searchHeaderController.view.snp.bottom)
			make.left.equalTo(self.view)
			make.bottom.equalTo(self.view)
			make.right.equalTo(self.view)
		}
	}

	// MARK: BaseContentViewController

	override func addLoaderView() {}
	override func refresh() {
		tracksViewController?.refresh()
	}

	override var shouldShowStickyTrack: Bool {
		false
	}
}
