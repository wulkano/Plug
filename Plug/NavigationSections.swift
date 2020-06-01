import Foundation

enum NavigationSection: Int {
	case popular = 0
	case favorites
	case latest
	case blogs
	case feed
	case genres
	case friends
	case search

	var title: String {
		switch self {
		case .popular:
			return "Popular"
		case .favorites:
			return "Favorites"
		case .latest:
			return "Latest"
		case .blogs:
			return "Blogs"
		case .feed:
			return "Feed"
		case .genres:
			return "Genres"
		case .friends:
			return "Friends"
		case .search:
			return "Search"
		}
	}

	var analyticsViewName: String { "MainWindow/\(title)" }
}

enum PopularSectionMode: String {
	case now = "Now"
	case noRemixes = "No Remixes"
	case onlyRemixes = "Only Remixes"
	case lastWeek = "Last Week"

	static let navigationSection = NavigationSection.popular

	var title: String { rawValue }

	var params: [String: Any] {
		[
			"mode": slug
		]
	}

	var slug: String {
		switch self {
		case .now:
			return "now"
		case .noRemixes:
			return "noremix"
		case .onlyRemixes:
			return "remix"
		case .lastWeek:
			return "lastweek"
		}
	}
}

enum FavoritesSectionPlaylist: String {
	case all = "All"
	case one = "Up"
	case two = "Down"
	case three = "Weird"

	static let navigationSection = NavigationSection.favorites

	var title: String { rawValue }
}

enum LatestSectionMode: String {
	case all = "All"
	case freshest = "Freshest"
	case noRemixes = "No Remixes"
	case onlyRemixes = "Only Remixes"

	static let navigationSection = NavigationSection.latest

	var title: String { rawValue }

	var params: [String: Any] {
		[
			"mode": slug
		]
	}

	var slug: String {
		switch self {
		case .all:
			return "all"
		case .freshest:
			return "fresh"
		case .noRemixes:
			return "noremix"
		case .onlyRemixes:
			return "remix"
		}
	}
}

enum FeedSectionMode: String {
	case all = "All"
	case friends = "Friends"
	case blogs = "Blogs"

	static let navigationSection = NavigationSection.feed

	var title: String { rawValue }

	var params: [String: Any] {
		[
			"mode": slug
		]
	}

	var slug: String {
		switch self {
		case .all:
			return "all"
		case .friends:
			return "friends"
		case .blogs:
			return "blogs"
		}
	}
}

enum SearchSectionSort: String {
	case newest = "Newest"
	case mostFavorites = "Most Favorites"
	case mostReblogged = "Most Reblogged"

	static let navigationSection = NavigationSection.search

	var title: String { rawValue }

	var params: [String: Any] {
		[
			"sort": slug
		]
	}

	var slug: String {
		switch self {
		case .newest:
			return "latest"
		case .mostFavorites:
			return "loved"
		case .mostReblogged:
			return "posted"
		}
	}
}
