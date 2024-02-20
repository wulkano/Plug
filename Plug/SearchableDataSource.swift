import Cocoa

// swiftlint:disable:next final_class
class SearchableDataSource: HypeMachineDataSource {
	var searchKeywords: String? {
		didSet {
			searchKeywordsChanged()
		}
	}

	func searchKeywordsChanged() {
		refilterTableContents()
		isFiltering = !(searchKeywords?.isEmpty == true || searchKeywords == nil)
	}

	// swiftlint:disable:next unavailable_function
	func filterObjectsMatchingSearchKeywords(_ objects: [Any]) -> [Any] {
		fatalError("filterObjectsMatchingKeywords: not implemented")
	}

	// MARK: HypeMachineDataSource

	override func filterTableContents(_ objects: [Any]) -> [Any] {
		if searchKeywords?.isEmpty == true || searchKeywords == nil {
			return objects
		}

		return filterObjectsMatchingSearchKeywords(objects)
	}
}
