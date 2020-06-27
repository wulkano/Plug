import Foundation
import Alamofire
import HypeMachineAPI

class PopularTracksDataSource: TracksDataSource {
	let mode: PopularSectionMode

	init(viewController: DataSourceViewController, mode: PopularSectionMode) {
		self.mode = mode
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override var objectsPerPage: Int { 50 }

	override var singlePage: Bool { true }

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Tracks.popular(params: mode.params.merge(nextPageParams), completionHandler: nextPageTracksReceived)
	}
}

final class FavoriteTracksDataSource: TracksDataSource {
	let playlist: FavoritesSectionPlaylist
	var shuffle = false

	init(viewController: DataSourceViewController, playlist: FavoritesSectionPlaylist) {
		self.playlist = playlist
		self.shuffle = AudioPlayer.shared.isShuffle
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override var nextPageParams: [String: Any] {
		if shuffle {
			return [
				"page": 1,
				"count": objectsPerPage,
				"shuffle": "1"
			]
		} else {
			return super.nextPageParams
		}
	}

	override func requestNextPageObjects() {
		switch playlist {
		case .all:
			HypeMachineAPI.Requests.Me.favorites(params: nextPageParams, completionHandler: nextPageTracksReceived)
		case .one:
			HypeMachineAPI.Requests.Me.showPlaylist(id: 1, params: nextPageParams, completionHandler: nextPageTracksReceived)
		case .two:
			HypeMachineAPI.Requests.Me.showPlaylist(id: 2, params: nextPageParams, completionHandler: nextPageTracksReceived)
		case .three:
			HypeMachineAPI.Requests.Me.showPlaylist(id: 3, params: nextPageParams, completionHandler: nextPageTracksReceived)
		}
	}

	override func nextPageTracksReceived(response: DataResponse<[HypeMachineAPI.Track]>) {
		nextPageResponseReceived(response)
		if shuffle {
			allObjectsLoaded = false

			if
				response.result.isSuccess,
				currentPage == 1
			{
				if let currentTrack = AudioPlayer.shared.currentTrack {
					if let indexOfCurrentlyPlayingTrack = (standardTableContents as! [HypeMachineAPI.Track]).firstIndex(of: currentTrack) {
						standardTableContents?.remove(at: indexOfCurrentlyPlayingTrack)
					}

					standardTableContents?.insert(currentTrack, at: 0)
					viewController.tableView.insertRows(at: IndexSet(integersIn: 0...1), withAnimation: NSTableView.AnimationOptions())
				}
			}
		}

		AudioPlayer.shared.findAndSetCurrentlyPlayingTrack()
	}
}

final class LatestTracksDataSource: TracksDataSource {
	let mode: LatestSectionMode

	init(viewController: DataSourceViewController, mode: LatestSectionMode) {
		self.mode = mode
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Tracks.index(params: mode.params.merge(nextPageParams), completionHandler: nextPageTracksReceived)
	}
}

final class FeedTracksDataSource: TracksDataSource {
	let mode: FeedSectionMode

	init(viewController: DataSourceViewController, mode: FeedSectionMode) {
		self.mode = mode
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Me.feed(params: mode.params.merge(nextPageParams), completionHandler: nextPageTracksReceived)
	}
}

final class BlogTracksDataSource: TracksDataSource {
	let blogID: Int

	init(viewController: DataSourceViewController, blogID: Int) {
		self.blogID = blogID
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Blogs.showTracks(id: blogID, params: nextPageParams, completionHandler: nextPageTracksReceived)
	}
}

final class UserTracksDataSource: TracksDataSource {
	let username: String

	init(viewController: DataSourceViewController, username: String) {
		self.username = username
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Users.showFavorites(username: username, params: nextPageParams, completionHandler: nextPageTracksReceived)
	}
}

final class ArtistTracksDataSource: TracksDataSource {
	let artistName: String

	init(viewController: DataSourceViewController, artistName: String) {
		self.artistName = artistName
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Artists.showTracks(name: artistName, params: nextPageParams, completionHandler: nextPageTracksReceived)
	}
}

final class TagTracksDataSource: TracksDataSource {
	let tagName: String

	init(viewController: DataSourceViewController, tagName: String) {
		self.tagName = tagName
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Tags.showTracks(name: tagName, params: nextPageParams, completionHandler: nextPageTracksReceived)
	}
}

final class SearchTracksDataSource: TracksDataSource {
	let searchQuery: String
	let sort: SearchSectionSort

	init(viewController: DataSourceViewController, sort: SearchSectionSort, searchQuery: String) {
		self.searchQuery = searchQuery
		self.sort = sort
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override func requestNextPageObjects() {
		HypeMachineAPI.Requests.Tracks.index(params: sort.params.merge(nextPageParams).merge(["q": searchQuery]), completionHandler: nextPageTracksReceived)
	}
}

final class SingleTrackDataSource: TracksDataSource {
	let track: HypeMachineAPI.Track

	init(viewController: DataSourceViewController, track: HypeMachineAPI.Track) {
		self.track = track
		super.init(viewController: viewController)
	}

	// MARK: HypeMachineDataSource

	override var singlePage: Bool { true }

	override func requestNextPageObjects() {
		let response = DataResponse(request: nil, response: nil, data: nil, result: Alamofire.Result.success([track]))
		nextPageTracksReceived(response: response)
	}
}
