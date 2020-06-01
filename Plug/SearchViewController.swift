import Cocoa

final class SearchViewController: BaseContentViewController {
	var searchResultsView: NSView!

	var sort: SearchSectionSort = .newest {
		didSet {
			sortChanged()
		}
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
			let tracksViewController = self.tracksViewController,
			let searchDataSource = tracksViewController.dataSource as? SearchTracksDataSource
		else {
			return
		}

		tracksViewController.dataSource = SearchTracksDataSource(
			viewController: tracksViewController,
			sort: sort,
			searchQuery: searchDataSource.searchQuery
		)
	}

	// MARK: NSView

	override func loadView() {
		super.loadView()

		let searchHeaderController = SearchHeaderViewController(nibName: nil, bundle: nil)
		view.addSubview(searchHeaderController.view)
		searchHeaderController.view.snp.makeConstraints { make in
			make.height.equalTo(52)
			make.top.equalTo(view)
			make.left.equalTo(view)
			make.right.equalTo(view)
		}
		searchHeaderController.searchField.target = self
		searchHeaderController.searchField.action = #selector(SearchViewController.searchFieldSubmit(_:))

		searchResultsView = NSView()
		view.addSubview(searchResultsView)
		searchResultsView.snp.makeConstraints { make in
			make.top.equalTo(searchHeaderController.view.snp.bottom)
			make.left.equalTo(view)
			make.bottom.equalTo(view)
			make.right.equalTo(view)
		}
	}

	// MARK: BaseContentViewController

	override func addLoaderView() {}
	override func refresh() {
		tracksViewController?.refresh()
	}

	override var shouldShowStickyTrack: Bool { false }
}
