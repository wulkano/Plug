import Cocoa
import HypeMachineAPI

final class BlogsDataSource: SearchableDataSource {
	func filterBlogs(_ contents: [Any]) -> [HypeMachineAPI.Blog] {
		contents.filter { $0 is HypeMachineAPI.Blog } as! [HypeMachineAPI.Blog]
	}

	func filterUniqueBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
		Array(Set(blogs))
	}

	func filterBlogsMatchingSearchKeywords(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
		blogs.filter { $0.name =~ self.searchKeywords! }
	}

	func filterFollowingBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
		blogs.filter { $0.following == true }
	}

	func filterFeaturedBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
		blogs.filter { $0.featured == true }
	}

	func sortBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
		blogs.sorted { $0.name.lowercased() < $1.name.lowercased() }
	}

	func groupBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [Any] {
		var groupedBlogs: [Any] = []

		let followingBlogs = filterFollowingBlogs(blogs)
		if !followingBlogs.isEmpty {
			let sortedFollowingBlogs = sortBlogs(followingBlogs)
			groupedBlogs.append(SectionHeader(title: "Following"))
			groupedBlogs += sortedFollowingBlogs as [Any]
		}

		let featuredBlogs = filterFeaturedBlogs(blogs)
		if !featuredBlogs.isEmpty {
			let sortedFeaturedBlogs = sortBlogs(featuredBlogs)
			groupedBlogs.append(SectionHeader(title: "Featured"))
			groupedBlogs += sortedFeaturedBlogs as [Any]
		}

		groupedBlogs.append(SectionHeader(title: "All Blogs"))
		let allSortedBlogs = sortBlogs(blogs)
		groupedBlogs += allSortedBlogs as [Any]

		return groupedBlogs
	}

	// MARK: SearchableDataSource

	override func filterObjectsMatchingSearchKeywords(_ objects: [Any]) -> [Any] {
		let blogs = filterBlogs(objects)
		let uniqueBlogs = filterUniqueBlogs(blogs)
		let sortedBlogs = sortBlogs(uniqueBlogs)

		if searchKeywords?.isEmpty == true || searchKeywords == nil {
			print("Filtering, but no keywords present")
			return sortedBlogs
		} else {
			return filterBlogsMatchingSearchKeywords(sortedBlogs)
		}
	}

	// MARK: HypeMachineDataSource

	override var singlePage: Bool {
		true
	}

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Blogs.index { response in
			self.nextPageResponseReceived(response)
		}
	}

	override func appendTableContents(_ contents: [Any]) {
		let blogs = contents as! [HypeMachineAPI.Blog]
		let groupedBlogs = groupBlogs(blogs)
		super.appendTableContents(groupedBlogs)
	}
}

enum BlogDirectoryItem {
	case sectionHeaderItem(SectionHeader)
	case blogItem(HypeMachineAPI.Blog)

	static func fromObject(_ object: Any) -> BlogDirectoryItem? {
		if object is HypeMachineAPI.Blog {
			return BlogDirectoryItem.blogItem(object as! HypeMachineAPI.Blog)
		} else if object is SectionHeader {
			return BlogDirectoryItem.sectionHeaderItem(object as! SectionHeader)
		} else {
			return nil
		}
	}
}
