import Cocoa
import Alamofire

// swiftlint:disable:next final_class
class HypeMachineDataSource: NSObject, NSTableViewDataSource {
	var viewController: DataSourceViewController

	var isFiltering = false {
		didSet {
			viewController.tableView.reloadData()
		}
	}

	var standardTableContents: [Any]?
	var filteredTableContents: [Any]?

	var tableContents: [Any]? {
		guard let standardTableContents = standardTableContents else {
			return nil
		}

		return isFiltering ? filteredTableContents! : standardTableContents
	}

	var requestInProgress = false
	var allObjectsLoaded = false
	var currentPage = 0
	var objectsPerPage: Int { 100 }

	var nextPageParams: [String: Any] {
		[
			"page": currentPage + 1,
			"count": objectsPerPage
		]
	}

	var singlePage: Bool { false }

	init(viewController: DataSourceViewController) {
		self.viewController = viewController
		super.init()
	}

	func loadNextPageObjects() {
		if singlePage, currentPage >= 1 {
			return
		}

		if requestInProgress {
			return
		}

		if allObjectsLoaded {
			return
		}

		requestInProgress = true
		requestNextPageObjects()
	}

	// swiftlint:disable:next unavailable_function
	func requestNextPageObjects() {
		fatalError("requestNextPage() not implemented")
	}

	func nextPageResponseReceived<T>(_ response: DataResponse<T>) {
		viewController.nextPageDidLoad(currentPage)

		switch response.result {
		case .success(let value):
			guard let objects = value as Any as? [Any] else {
				fatalError("Must be of type [Any]")
			}

			if currentPage == 0 {
				resetTableContents()
			}

			currentPage += 1
			allObjectsLoaded = isLastPage(objects)

			appendTableContents(objects)
			requestInProgress = false
		case .failure(let error):
			Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
			print(error)
		}
	}

	func refresh() {
		currentPage = 0
		allObjectsLoaded = false
		loadNextPageObjects()
	}

	func isLastPage(_ objects: [Any]) -> Bool {
		objects.count < objectsPerPage
	}

	func objectForRow(_ row: Int) -> Any? {
		tableContents?.optionalAtIndex(row)
	}

	func objectAfterRow(_ row: Int) -> Any? {
		objectForRow(row + 1)
	}

	func resetTableContents() {
		standardTableContents = nil
		filteredTableContents = nil
	}

	func appendTableContents(_ objects: [Any]) {
		var shouldReloadTableView = false
		let filteredObjects = filterTableContents(objects)

		if standardTableContents == nil {
			standardTableContents = []
			filteredTableContents = []
			shouldReloadTableView = true
		}

		let objectsToAdd: [Any]
		if isFiltering {
			objectsToAdd = filteredObjects
		} else {
			objectsToAdd = objects
		}

		let rowIndexSet = rowIndexSetForNewObjects(objectsToAdd)

		// Need to calc the row index set first so that we can count the number of existing objects
		standardTableContents! += objects
		filteredTableContents! += filteredObjects

		if shouldReloadTableView {
			viewController.tableView.reloadData()
		} else {
			viewController.tableView.insertRows(at: rowIndexSet, withAnimation: NSTableView.AnimationOptions())
		}
	}

	func rowIndexSetForNewObjects(_ objects: [Any]) -> IndexSet {
		let rowRange = NSRange(location: tableContents!.count, length: objects.count)
		return IndexSet(integersIn: Range(rowRange) ?? 0..<0)
	}

	func filterTableContents(_ objects: [Any]) -> [Any] {
		print("filterTableContents() not implemented")
		return objects
	}

	func refilterTableContents() {
		filteredTableContents = filterTableContents(standardTableContents!)
	}

	// MARK: NSTableViewDelegate

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		objectForRow(row)
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		tableContents?.count ?? 0
	}
}
