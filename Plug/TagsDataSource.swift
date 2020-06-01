import Cocoa
import HypeMachineAPI

final class TagsDataSource: SearchableDataSource {
	func filterTags(_ contents: [Any]) -> [HypeMachineAPI.Tag] {
		contents.filter { $0 is HypeMachineAPI.Tag } as? [HypeMachineAPI.Tag] ?? []
	}

	func filterUniqueTags(_ tags: [HypeMachineAPI.Tag]) -> [HypeMachineAPI.Tag] {
		Array(Set(tags))
	}

	func filterTagsMatchingSearchKeywords(_ tags: [HypeMachineAPI.Tag]) -> [HypeMachineAPI.Tag] {
		tags.filter { $0.name =~ self.searchKeywords! }
	}

	func sortTags(_ tags: [HypeMachineAPI.Tag]) -> [HypeMachineAPI.Tag] {
		if tags.count > 1 {
			return tags.sorted { $0.name.lowercased() < $1.name.lowercased() }
		} else {
			return tags
		}
	}

	func groupTags(_ tags: [HypeMachineAPI.Tag]) -> [Any] {
		var groupedTags: [AnyObject] = []

		groupedTags.append(SectionHeader(title: "The Basics"))
		var priorityTags = tags.filter { $0.priority == true }
		priorityTags = priorityTags.sorted { $0.name.lowercased() < $1.name.lowercased() }
		groupedTags += priorityTags as [AnyObject]

		groupedTags.append(SectionHeader(title: "Everything"))
		let sortedTags = tags.sorted { $0.name.lowercased() < $1.name.lowercased() }
		groupedTags += sortedTags as [AnyObject]

		return groupedTags
	}

	func newTag(_ searchKeywords: String) -> [HypeMachineAPI.Tag] {
		let newTag = Tag(name: searchKeywords, priority: false)
		return [newTag]
	}

	// MARK: SearchableDataSource

	override func filterObjectsMatchingSearchKeywords(_ objects: [Any]) -> [Any] {
		let tags = filterTags(objects)
		let uniqueTags = filterUniqueTags(tags)
		let sortedTags = sortTags(uniqueTags)

		if searchKeywords?.isEmpty == true || searchKeywords == nil {
			print("Filtering, but no keywords present")
			return sortedTags
		} else {
			// Has keywords so filter tags using keywords
			let filteredResults = filterTagsMatchingSearchKeywords(sortedTags)

			// If results of filter are zero then try and make a new object using the keywords
			if filteredResults.isEmpty {
				// Make a new tag using the search Keyword
				return newTag(searchKeywords!)
			} else {
				return filteredResults
			}
		}
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Tags.index { response in
			self.nextPageResponseReceived(response)
		}
	}

	override func appendTableContents(_ contents: [Any]) {
		let tags = contents as! [HypeMachineAPI.Tag]
		let groupedTags = groupTags(tags)
		super.appendTableContents(groupedTags)
	}
}

enum TagsListItem {
	case sectionHeaderItem(SectionHeader)
	case tagItem(HypeMachineAPI.Tag)

	static func fromObject(_ object: Any) -> TagsListItem? {
		if let tag = object as? HypeMachineAPI.Tag {
			return TagsListItem.tagItem(tag)
		} else if let sectionHeader = object as? SectionHeader {
			return TagsListItem.sectionHeaderItem(sectionHeader)
		} else {
			return nil
		}
	}
}
