import Cocoa
import MediaPlayer
import HypeMachineAPI

final class MainWindowController: NSWindowController {
	var trafficButtons: TrafficButtons!
	// Kinda janky, but no way AFAIK to set @available on properties
	var _nowPlayingInfoCenter: NSObject?
	var _nowPlayingInfo: Any?
	var _remoteCommandCenter: NSObject?

	override func windowDidLoad() {
		super.windowDidLoad()

		trafficButtons = TrafficButtons(style: .dark, groupIdentifier: "MainWindow")
		trafficButtons.addButtonsToWindow(window!, origin: CGPoint(x: 8, y: 10))

		if #available(OSX 10.12.2, *) {
			setupRemoteCommandCenter()
		}
	}

	deinit {
		if #available(OSX 10.12.2, *) {
			tearDownRemoteCommandCenter()
		}
	}

	override func keyDown(with theEvent: NSEvent) {
		// 49 is the key for the space bar
		if theEvent.keyCode == 49 {
			AudioPlayer.shared.playPauseToggle()
		}
	}
}

// MARK: RemoteCommandCenter

@available(OSX 10.12.2, *)
extension MainWindowController {
	func tearDownRemoteCommandCenter() {
		Notifications.unsubscribeAll(observer: self)
	}

	// Hacking in some @available properties

	var nowPlayingInfoCenter: MPNowPlayingInfoCenter {
		get { _nowPlayingInfoCenter as! MPNowPlayingInfoCenter }
		set { _nowPlayingInfoCenter = newValue }
	}

	var nowPlayingInfo: [String: Any] {
		get { _nowPlayingInfo as! [String: Any] }
		set { _nowPlayingInfo = newValue }
	}

	var remoteCommandCenter: MPRemoteCommandCenter {
		get { _remoteCommandCenter as! MPRemoteCommandCenter }
		set { _remoteCommandCenter = newValue }
	}

	func setupRemoteCommandCenter() {
		// Setup properties
		nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
		remoteCommandCenter = MPRemoteCommandCenter.shared()

		// Notifications
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfo), name: Notifications.NewCurrentTrack, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfoCenterPlaybackStatePlaying), name: Notifications.TrackPlaying, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfoCenterPlaybackStatePaused), name: Notifications.TrackPaused, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(MainWindowController.updateNowPlayingInfoElapsedPlaybackTime), name: Notifications.TrackProgressUpdated, object: nil)

		// Play/pause toggle
		remoteCommandCenter.playCommand.activate(self, action: #selector(togglePlayPause(event:)))
		remoteCommandCenter.pauseCommand.activate(self, action: #selector(togglePlayPause(event:)))

		// Previous/next track toggle
		// Apparently these work only on 10.12.2+
		remoteCommandCenter.previousTrackCommand.activate(self, action: #selector(previousTrack(event:)))
		remoteCommandCenter.nextTrackCommand.activate(self, action: #selector(nextTrack(event:)))

		// Scrub bar control
		remoteCommandCenter.changePlaybackPositionCommand.activate(self, action: #selector(changePlaybackPosition(event:)))
	}


	// MARK: TouchBar playback controls

	@objc
	func togglePlayPause(event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
		AudioPlayer.shared.playPauseToggle()
		nowPlayingInfoCenter.playbackState = AudioPlayer.shared.playing ? .playing : .paused

		return .success
	}

	@objc
	func changePlaybackPosition(event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
		guard
			let duration = self.nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] as? Double
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
			MPMediaItemPropertyTitle: track.title,
			MPMediaItemPropertyArtist: track.artist,
			MPNowPlayingInfoPropertyElapsedPlaybackTime: 0.0,
			MPMediaItemPropertyPlaybackDuration: 200.0, // Set aribitrary value that looks about until update received
			MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
		]

		nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
		nowPlayingInfoCenter.playbackState = AudioPlayer.shared.playing ? .playing : .paused
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
		let progress = ((notification as NSNotification).userInfo!["progress"] as! NSNumber).doubleValue
		let duration = ((notification as NSNotification).userInfo!["duration"] as! NSNumber).doubleValue
		nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = progress
		nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration

		nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
	}
}
