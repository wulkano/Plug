import Cocoa
import MediaPlayer
import HypeMachineAPI

final class MainWindowController: NSWindowController {
	private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
	private let remoteCommandCenter = MPRemoteCommandCenter.shared()
	private var nowPlayingInfo = [String: Any]()

	override func windowDidLoad() {
		super.windowDidLoad()

		window?.isExcludedFromWindowsMenu = true
		window?.titleVisibility = .hidden
		window?.toolbar = NSToolbar()

		setupRemoteCommandCenter()
	}

	deinit {
		tearDownRemoteCommandCenter()
	}

	override func keyDown(with theEvent: NSEvent) {
		// `49` is the key for the space bar.
		if theEvent.keyCode == 49 {
			AudioPlayer.shared.playPauseToggle()
		}
	}
}

// MARK: RemoteCommandCenter

extension MainWindowController {
	func tearDownRemoteCommandCenter() {
		Notifications.unsubscribeAll(observer: self)
	}

	func setupRemoteCommandCenter() {
		// Notifications
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfo), name: Notifications.NewCurrentTrack, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfoCenterPlaybackStatePlaying), name: Notifications.TrackPlaying, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfoCenterPlaybackStatePaused), name: Notifications.TrackPaused, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfoElapsedPlaybackTime), name: Notifications.TrackProgressUpdated, object: nil)

		// Play/pause toggle
		remoteCommandCenter.playCommand.activate(self, action: #selector(togglePlayPause(event:)))
		remoteCommandCenter.pauseCommand.activate(self, action: #selector(togglePlayPause(event:)))
		remoteCommandCenter.togglePlayPauseCommand.activate(self, action: #selector(togglePlayPause(event:)))

		// Previous/next track toggle
		remoteCommandCenter.previousTrackCommand.activate(self, action: #selector(previousTrack(event:)))
		remoteCommandCenter.nextTrackCommand.activate(self, action: #selector(nextTrack(event:)))

		// Scrub bar control
		remoteCommandCenter.changePlaybackPositionCommand.activate(self, action: #selector(changePlaybackPosition(event:)))
	}


	// MARK: TouchBar playback controls

	@objc
	func togglePlayPause(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
		AudioPlayer.shared.playPauseToggle()
		nowPlayingInfoCenter.playbackState = AudioPlayer.shared.isPlaying ? .playing : .paused

		return .success
	}

	@objc
	func changePlaybackPosition(event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
		guard
			let duration = nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] as? Double
		else {
			return .noActionableNowPlayingItem
		}

		let position = event.positionTime.rounded() / duration
		AudioPlayer.shared.seekToPercent(position)

		return .success
	}

	@objc
	func previousTrack(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
		AudioPlayer.shared.skipBackward()

		return .success
	}

	@objc
	func nextTrack(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
		AudioPlayer.shared.skipForward()

		return .success
	}

	// MARK: TouchBar info refresh

	@objc
	func updateNowPlayingInfo(_ notification: Notification) {
		let track = notification.userInfo!["track"] as! HypeMachineAPI.Track

		// First reset the playback state
		// This fixes occasional stuck progress bar after track end
		nowPlayingInfoCenter.playbackState = .interrupted

		nowPlayingInfo = [
			MPNowPlayingInfoPropertyExternalContentIdentifier: track.id,
			MPMediaItemPropertyTitle: track.title,
			MPMediaItemPropertyArtist: track.artist,
			MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0,
			MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue,
			MPNowPlayingInfoPropertyAssetURL: track.mediaURL()
		]

		nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
		nowPlayingInfoCenter.playbackState = AudioPlayer.shared.isPlaying ? .playing : .paused

		if let thumbnailUrl = track.thumbURLLarge {
			DispatchQueue.global().async { [weak self] in
				guard
					let self,
					let image = NSImage(contentsOf: thumbnailUrl)
				else {
					return
				}

				let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
				self.nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
				self.nowPlayingInfoCenter.nowPlayingInfo = self.nowPlayingInfo
			}
		}
	}

	@objc
	func updateNowPlayingInfoCenterPlaybackStatePlaying(_ notification: Notification) {
		nowPlayingInfoCenter.playbackState = .playing
	}

	@objc
	func updateNowPlayingInfoCenterPlaybackStatePaused(_ notification: Notification) {
		nowPlayingInfoCenter.playbackState = .paused
	}

	@objc
	func updateNowPlayingInfoElapsedPlaybackTime(_ notification: Notification) {
		let progress = (notification.userInfo!["progress"] as! NSNumber).doubleValue
		let duration = (notification.userInfo!["duration"] as! NSNumber).doubleValue
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration

		nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
	}
}
