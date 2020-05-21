import Cocoa
import AVFoundation
import CoreMedia
import HypeMachineAPI

typealias OnShuffleChangedSwignal = Swignal1Arg<Bool>
typealias OnTrackPlaying = Swignal1Arg<Bool>
typealias OnTrackPaused = Swignal1Arg<Bool>
typealias OnSkipForward = Swignal1Arg<Bool>
typealias OnSkipBackward = Swignal1Arg<Bool>

final class AudioPlayer: NSObject {
	static var shared = AudioPlayer()

	var player: AVPlayer!
	var playerItem: AVPlayerItem!
	var currentDataSource: TracksDataSource! {
		didSet {
			recentlyPlayedTrackIndexes = []
		}
	}

	var currentTrack: HypeMachineAPI.Track? {
		didSet {
			currentTrackChanged()
		}
	}

	var currentTrackListenLogged = false
	var currentTrackListenScrobbled = false
	var playing: Bool = false
	var shuffle: Bool = false {
		didSet {
			onShuffleChanged.fire(shuffle)
			UserDefaults.standard.setValue(shuffle, forKey: "shuffle")
		}
	}

	let onShuffleChanged = OnShuffleChangedSwignal()
	let onTrackPlaying = OnTrackPlaying()
	let onTrackPaused = OnTrackPaused()
	let onSkipForward = OnSkipForward()
	let onSkipBackward = OnSkipBackward()

	@objc dynamic var volume: Float = 1 {
		didSet {
			volumeChanged()
		}
	}

	var progressObserver: AnyObject?
	var seeking = false
	var recentlyPlayedTrackIndexes = [Int]()
	var timeoutTimer: Timer?
	let timeoutSeconds: Double = 10

	override init() {
		self.shuffle = UserDefaults.standard.value(forKey: "shuffle") as! Bool
		super.init()

		bind(NSBindingName("volume"), to: NSUserDefaultsController.shared, withKeyPath: "values.volume", options: nil)
	}

	deinit {
		if progressObserver != nil {
			player.removeTimeObserver(progressObserver!)
		}
	}

	func reset() {
		if progressObserver != nil {
			player.removeTimeObserver(progressObserver!)
		}

		player = nil
		playerItem = nil
		currentDataSource = nil
		currentTrack = nil
		playing = false
		progressObserver = nil
		seeking = false
	}

	func playNewTrack(_ track: HypeMachineAPI.Track, dataSource: TracksDataSource) {
		if currentTrack != track {
			setupForNewTrack(track, dataSource: dataSource)
			UserNotifications.deliverNotification(title: track.title, informativeText: track.artist)
			Notifications.post(name: Notifications.NewCurrentTrack, object: self, userInfo: ["track": track, "tracksDataSource": dataSource])
		}

		play()
	}

	func findAndSetCurrentlyPlayingTrack() {
		guard
			currentDataSource != nil,
			currentTrack != nil,
			let foundTracks = findTracksWithTrackId(currentTrack!.id)
		else {
			return
		}

		if foundTracks.firstIndex(of: currentTrack!) != NSNotFound {
			// Current track is already accurate.
			return
		} else if let foundTrack = foundTracks.first {
			if currentTrack != foundTrack {
				currentTrack = foundTrack
			}
		}
	}

	fileprivate func findTracksWithTrackId(_ trackId: String) -> [Track]? {
		currentDataSource.tableContents?.filter { ($0 as! HypeMachineAPI.Track).id == trackId } as? [Track]
	}

	func play() {
		player.play()
		playing = true
		Notifications.post(name: Notifications.TrackPlaying, object: self, userInfo: ["track" as NSObject: currentTrack!])
		onTrackPlaying.fire(true)
	}

	func pause() {
		player.pause()
		playing = false
		Notifications.post(name: Notifications.TrackPaused, object: self, userInfo: ["track" as NSObject: currentTrack!])
		onTrackPaused.fire(true)
	}

	func playPauseToggle() {
		guard currentTrack != nil else {
			return
		}

		if playing {
			pause()
		} else {
			play()
		}
	}

	func skipForward() {
		guard currentDataSource != nil else {
			return
		}

		onSkipForward.fire(true)

		if let nextTrack = findNextTrack() {
			playNewTrack(nextTrack, dataSource: currentDataSource)
		}
	}

	func skipBackward() {
		guard
			currentDataSource != nil,
			currentTrack != nil
		else {
			return
		}

		onSkipBackward.fire(true)

		if let previousTrack = currentDataSource.trackBefore(currentTrack!) {
			playNewTrack(previousTrack, dataSource: currentDataSource)
		} else {
			seekToPercent(0)
		}
	}

	func toggleShuffle() {
		shuffle.toggle()
	}

	func seekToPercent(_ percent: Double) {
		guard playerItem != nil && playerItem.status == AVPlayerItem.Status.readyToPlay
		else { return }

		seeking = true
		let seconds = percent * currentItemDuration()!
		let time = CMTimeMakeWithSeconds(seconds, preferredTimescale: 1000)

		player.seek(to: time) { success in
			self.seeking = false

			if !success {
				// Minor error
				print("Error seeking")
			}
		}
	}

	// MARK: Notification listeners

	@objc
	func currentTrackFinishedPlayingNotification(_ notification: Notification) {
		print("currentTrackFinishedPlayingNotification")
		skipForward()
	}

	@objc
	func currentTrackCouldNotFinishPlayingNotification(_ notification: Notification) {
		let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Streaming error. Skipping to next track."])
		currentTrackPlaybackError(error)
	}

	@objc
	func currentTrackPlaybackStalledNotification(_ notification: Notification) {
		let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Streaming error. Skipping to next track."])
		currentTrackPlaybackError(error)
	}

	@objc
	func currentTrackNewAccessLogEntry(_ notification: Notification) {
//		  print((notification.object as! AVPlayerItem).accessLog())
	}

	@objc
	func currentTrackNewErrorLogEntry(_ notification: Notification) {
		print((notification.object as! AVPlayerItem).errorLog())
	}

	func currentTrackPlaybackError(_ error: NSError) {
		Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error" as NSObject: error])
		print(error)
		skipForward()
	}

	@objc
	func didAVPlayerTimeout() {
		guard player != nil else {
			return
		}

		if let value = player.currentItem?.loadedTimeRanges.optionalAtIndex(0) {
			var timeRange = CMTimeRange()
			value.getValue(&timeRange)
			let duration = timeRange.duration
			let timeLoaded = Float(duration.value) / Float(duration.timescale)

			if timeLoaded == 0 {
				avPlayerTimedOut()
			}
		} else {
			avPlayerTimedOut()
		}
	}

	func avPlayerTimedOut() {
		let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Network error. Track took too long to load, skipping to next track."])
		currentTrackPlaybackError(error)
	}

	// MARK: Private methods

	fileprivate func currentItemDuration() -> Double? {
		guard let seconds = playerItem?.duration.seconds else {
			return nil
		}

		return seconds
	}

	fileprivate func setupForNewTrack(_ track: HypeMachineAPI.Track, dataSource: TracksDataSource) {
		Analytics.trackAudioPlaybackEvent("Play New Track")

		if playerItem != nil {
			unsubscribeFromPlayerItem(playerItem)
		}

		playerItem = AVPlayerItem(url: track.mediaURL())

		subscribeToPlayerItem(playerItem)

		if player != nil && progressObserver != nil {
			player.removeTimeObserver(progressObserver!)
		}

		timeoutTimer?.invalidate()
		timeoutTimer = Timer.scheduledTimer(timeInterval: timeoutSeconds, target: self, selector: #selector(AudioPlayer.didAVPlayerTimeout), userInfo: nil, repeats: false)

		player = AVPlayer(playerItem: playerItem)
		player.volume = volume
		observeProgressUpdates()

		if currentDataSource != dataSource {
			currentDataSource = dataSource
		}
		currentTrack = track
		recentlyPlayedTrackIndexes.append(currentDataSource.indexOfTrack(currentTrack!)!)
	}

	func currentTrackChanged() {
		currentTrackListenLogged = false
		currentTrackListenScrobbled = false
	}

	fileprivate func volumeChanged() {
		if player != nil {
			player.volume = volume
		}
	}

	fileprivate func observeProgressUpdates() {
		let thirdOfSecond = CMTimeMake(value: 1, timescale: 3)
		progressObserver = player.addPeriodicTimeObserver(forInterval: thirdOfSecond, queue: nil, using: progressUpdated) as AnyObject?
	}

	fileprivate func progressUpdated(_ time: CMTime) {
		guard
			!seeking,
			currentTrack != nil
		else { return }

		let progress = time.seconds
		let duration = playerItem.duration.seconds
		let userInfo: [String: Any] = [
			"progress": progress,
			"duration": duration,
			"track": currentTrack!
		]
		Notifications.post(name: Notifications.TrackProgressUpdated, object: self, userInfo: userInfo)

		if progress > 30 && !currentTrackListenLogged {
			HypeMachineAPI.Requests.Me.postHistory(id: currentTrack!.id, position: 30) { _ in }
			currentTrackListenLogged = true
		} else if (progress / duration) > (2 / 3) && !currentTrackListenScrobbled {
			HypeMachineAPI.Requests.Me.postHistory(id: currentTrack!.id, position: Int(progress)) { _ in }
			currentTrackListenScrobbled = true
		}
	}

	fileprivate func playerItemNotificationNamesAndSelectors() -> [String: Selector] {
		[
			NSNotification.Name.AVPlayerItemDidPlayToEndTime.rawValue: #selector(AudioPlayer.currentTrackFinishedPlayingNotification(_:)),
			NSNotification.Name.AVPlayerItemFailedToPlayToEndTime.rawValue: #selector(AudioPlayer.currentTrackCouldNotFinishPlayingNotification(_:)),
			NSNotification.Name.AVPlayerItemPlaybackStalled.rawValue: #selector(AudioPlayer.currentTrackPlaybackStalledNotification(_:)),
			NSNotification.Name.AVPlayerItemNewAccessLogEntry.rawValue: #selector(AudioPlayer.currentTrackNewAccessLogEntry(_:)),
			NSNotification.Name.AVPlayerItemNewErrorLogEntry.rawValue: #selector(AudioPlayer.currentTrackNewErrorLogEntry(_:))
		]
	}

	fileprivate func subscribeToPlayerItem(_ playerItem: AVPlayerItem) {
		for (name, selector) in playerItemNotificationNamesAndSelectors() {
			NotificationCenter.default.addObserver(self, selector: selector, name: NSNotification.Name(rawValue: name), object: playerItem)
		}
	}

	fileprivate func unsubscribeFromPlayerItem(_ playerItem: AVPlayerItem) {
		for (name, _) in playerItemNotificationNamesAndSelectors() {
			NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: name), object: playerItem)
		}
	}

	fileprivate func findNextTrack() -> HypeMachineAPI.Track? {
		guard currentTrack != nil
		else { return nil }

		if shuffle &&
			!(currentDataSource is FavoriteTracksDataSource) {
			return nextShuffleTrack()
		} else {
			return currentDataSource.trackAfter(currentTrack!)
		}
	}

	fileprivate func nextShuffleTrack() -> HypeMachineAPI.Track? {
		if recentlyPlayedTrackIndexes.count >= currentDataSource.tableContents!.count {
			recentlyPlayedTrackIndexes = []
		}

		var nextShuffleTrackIndex = Rand.inRange(0..<currentDataSource.tableContents!.count)

		while recentlyPlayedTrackIndexes.firstIndex(of: nextShuffleTrackIndex) != nil {
			nextShuffleTrackIndex = Rand.inRange(0..<currentDataSource.tableContents!.count)
		}

		return currentDataSource.trackAtIndex(nextShuffleTrackIndex)
	}
}
