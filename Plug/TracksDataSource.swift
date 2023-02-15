import Cocoa
import Alamofire
import HypeMachineAPI

// swiftlint:disable:next final_class
class TracksDataSource: HypeMachineDataSource {
	let infiniteLoadTrackCountFromEnd = 7

	func nextPageTracksReceived(response: DataResponse<[HypeMachineAPI.Track]>) {
		nextPageResponseReceived(response)
		AudioPlayer.shared.findAndSetCurrentlyPlayingTrack()
	}

	func trackAfter(_ track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
		guard let currentIndex = indexOfTrack(track) else {
			return nil
		}

		if currentIndex + 1 >= max(0, tableContents!.count - infiniteLoadTrackCountFromEnd) {
			loadNextPageObjects()
		}

		let track = trackAtIndex(currentIndex + 1)
		if track != nil, track!.audioUnavailable {
			return trackAfter(track!)
		}

		return track
	}

	func trackBefore(_ track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
		guard let currentIndex = indexOfTrack(track) else {
			return nil
		}

		let track = trackAtIndex(currentIndex - 1)
		if
			track != nil,
			track!.audioUnavailable
		{
			return trackBefore(track!)
		}

		return track
	}

	func indexOfTrack(_ track: HypeMachineAPI.Track) -> Int? {
		guard let tracks = tableContents as? [HypeMachineAPI.Track] else {
			return nil
		}

		return tracks.firstIndex(of: track)
	}

	func trackAtIndex(_ index: Int) -> HypeMachineAPI.Track? {
		guard
			let tracks = tableContents as? [HypeMachineAPI.Track],
			index >= 0,
			index <= tracks.count - 1
		else {
			return nil
		}

		return tracks[index]
	}

	// MARK: HypeMachineDataSource

	override func filterTableContents(_ contents: [Any]) -> [Any] {
		let tracks = contents as? [HypeMachineAPI.Track]
		return tracks?.filter { !$0.audioUnavailable } ?? []
	}
}
