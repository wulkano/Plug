import Cocoa
import Alamofire
import HypeMachineAPI

class TracksDataSource: HypeMachineDataSource {
	let infiniteLoadTrackCountFromEnd = 7

	func nextPageTracksReceived(response: DataResponse<[HypeMachineAPI.Track]>) {
		nextPageResponseReceived(response)
		AudioPlayer.shared.findAndSetCurrentlyPlayingTrack()
	}

	func trackAfter(_ track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
		if let currentIndex = indexOfTrack(track) {
			if currentIndex + 1 >= max(0, tableContents!.count - infiniteLoadTrackCountFromEnd) {
				loadNextPageObjects()
			}

			let track = trackAtIndex(currentIndex + 1)
			if track != nil && track!.audioUnavailable {
				return trackAfter(track!)
			}

			return track
		} else {
			return nil
		}
	}

	func trackBefore(_ track: HypeMachineAPI.Track) -> HypeMachineAPI.Track? {
		if let currentIndex = indexOfTrack(track) {
			let track = trackAtIndex(currentIndex - 1)
			if track != nil && track!.audioUnavailable {
				return trackBefore(track!)
			}

			return track
		} else {
			return nil
		}
	}

	func indexOfTrack(_ track: HypeMachineAPI.Track) -> Int? {
		guard let tracks = tableContents as? [HypeMachineAPI.Track] else {
			return nil
		}

		return tracks.firstIndex(of: track)
	}

	func trackAtIndex(_ index: Int) -> HypeMachineAPI.Track? {
		guard let tracks = tableContents as? [HypeMachineAPI.Track] else {
			return nil
		}

		if index >= 0 && index <= tracks.count - 1 {
			return tracks[index]
		} else {
			return nil
		}
	}

	// MARK: HypeMachineDataSource

	override func filterTableContents(_ contents: [Any]) -> [Any] {
		let tracks = contents as? [HypeMachineAPI.Track]
		return tracks?.filter { !$0.audioUnavailable } ?? []
	}
}
