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
			"Popular"
		case .favorites:
			"Favorites"
		case .latest:
			"Latest"
		case .blogs:
			"Blogs"
		case .feed:
			"Feed"
		case .genres:
			"Genres"
		case .friends:
			"Friends"
		case .search:
			"Search"
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
			"now"
		case .noRemixes:
			"noremix"
		case .onlyRemixes:
			"remix"
		case .lastWeek:
			"lastweek"
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
			"all"
		case .freshest:
			"fresh"
		case .noRemixes:
			"noremix"
		case .onlyRemixes:
			"remix"
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
			"all"
		case .friends:
			"friends"
		case .blogs:
			"blogs"
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
			"latest"
		case .mostFavorites:
			"loved"
		case .mostReblogged:
			"posted"
		}
	}
}
