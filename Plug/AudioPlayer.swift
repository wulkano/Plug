import Cocoa
import AVFoundation
import CoreMedia
import UserNotifications
import Combine
import HypeMachineAPI

typealias OnShuffleChangedSwignal = Swignal1Arg<Bool>
typealias OnTrackPlaying = Swignal1Arg<Bool>
typealias OnTrackPaused = Swignal1Arg<Bool>
typealias OnSkipForward = Swignal1Arg<Bool>
typealias OnSkipBackward = Swignal1Arg<Bool>

final class AudioPlayer: NSObject {
	static let shared = AudioPlayer()

	private var playerDidChangeSubject = PassthroughSubject<Void, Never>()

	var playerDidChangePublisher: AnyPublisher<Void, Never> {
		playerDidChangeSubject.eraseToAnyPublisher()
	}

	var player: AVPlayer? {
		didSet {
			playerDidChangeSubject.send()
		}
	}

	var playerItem: AVPlayerItem?

	var currentDataSource: TracksDataSource? {
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
	var isPlaying = false

	var isShuffle = false {
		didSet {
			onShuffleChanged.fire(isShuffle)
			UserDefaults.standard.setValue(isShuffle, forKey: "shuffle")
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
	var isSeeking = false
	var recentlyPlayedTrackIndexes = [Int]()
	var timeoutTimer: Timer?
	let timeoutSeconds = 20.0

	var previousTrack: HypeMachineAPI.Track? {
		guard let currentTrack else {
			return nil
		}

		return currentDataSource?.trackBefore(currentTrack)
	}

	var hasNextTrack: Bool { findNextTrack() != nil }
	var hasPreviousTrack: Bool { previousTrack != nil }

	override private init() {
		self.isShuffle = UserDefaults.standard.value(forKey: "shuffle") as? Bool ?? false
		super.init()

		bind(NSBindingName("volume"), to: NSUserDefaultsController.shared, withKeyPath: "values.volume", options: nil)
	}

	deinit {
		if
			let player,
			let progressObserver
		{
			player.removeTimeObserver(progressObserver)
		}
	}

	func reset() {
		if
			let player,
			let progressObserver
		{
			player.removeTimeObserver(progressObserver)
		}

		player = nil
		playerItem = nil
		currentDataSource = nil
		currentTrack = nil
		isPlaying = false
		progressObserver = nil
		isSeeking = false
	}

	func playNewTrack(_ track: HypeMachineAPI.Track, dataSource: TracksDataSource) {
		if currentTrack != track {
			setupForNewTrack(track, dataSource: dataSource)

			Notifications.post(name: Notifications.NewCurrentTrack, object: self, userInfo: ["track": track, "tracksDataSource": dataSource])

			func notify(url: URL? = nil) {
				let notificationContent = UNMutableNotificationContent()
				notificationContent.title = track.title
				notificationContent.subtitle = track.artist

				if
					let url,
					let attachment = try? UNNotificationAttachment(identifier: "albumArt", url: url, options: nil)

				{
					notificationContent.attachments = [attachment]
				}

				let request = UNNotificationRequest(identifier: "trackInfo", content: notificationContent, trigger: nil)
				UNUserNotificationCenter.current().add(request)
			}

			DispatchQueue.global().async {
				guard UserDefaults.standard.bool(forKey: showTrackChangeNotificationsKey) else {
					return
				}

				// TODO: Remove this and enable the below when notifications on macOS shows the attachment. (not working as of macOS 11.5)
				notify()

//				guard
//					let url = track.thumbURLLarge,
//					let image = NSImage(contentsOf: url)
//				else {
//					notify()
//					return
//				}
//
//				let weakFileUrl = try? URL.uniqueTemporaryDirectory()
//					.appendingPathComponent(track.id, conformingTo: .png)
//
//				guard
//					let fileUrl = weakFileUrl,
//					(try? image.pngData()?.write(to: fileUrl)) != nil
//				else {
//					notify()
//					return
//				}
//
//				notify(url: fileUrl)
			}
		}

		play()
	}

	func findAndSetCurrentlyPlayingTrack() {
		guard
			currentDataSource != nil,
			let currentTrack
		else {
			return
		}

		let foundTracks = findTracksWithTrackId(currentTrack.id)
		guard !foundTracks.isEmpty else {
			return
		}

		if foundTracks.firstIndex(of: currentTrack) != NSNotFound {
			// Current track is already accurate.
			return
		}

		if let foundTrack = foundTracks.first {
			if currentTrack != foundTrack {
				self.currentTrack = foundTrack
			}
		}
	}

	fileprivate func findTracksWithTrackId(_ trackId: String) -> [Track] {
		currentDataSource?.tableContents?.filter { ($0 as? HypeMachineAPI.Track)?.id == trackId } as? [Track] ?? []
	}

	func play() {
		guard let player else {
			return
		}

		player.play()
		isPlaying = true
		Notifications.post(name: Notifications.TrackPlaying, object: self, userInfo: ["track" as NSObject: currentTrack!])
		onTrackPlaying.fire(true)
	}

	func pause() {
		guard let player else {
			return
		}

		player.pause()
		isPlaying = false
		Notifications.post(name: Notifications.TrackPaused, object: self, userInfo: ["track" as NSObject: currentTrack!])
		onTrackPaused.fire(true)
	}

	func playPauseToggle() {
		guard currentTrack != nil else {
			return
		}

		if isPlaying {
			pause()
		} else {
			play()
		}
	}

	func skipForward() {
		guard let currentDataSource else {
			return
		}

		onSkipForward.fire(true)

		if let nextTrack = findNextTrack() {
			playNewTrack(nextTrack, dataSource: currentDataSource)
		}
	}

	func skipBackward() {
		guard let currentDataSource else {
			return
		}

		onSkipBackward.fire(true)

		guard let previousTrack else {
			seekToPercent(0)
			return
		}

		playNewTrack(previousTrack, dataSource: currentDataSource)
	}

	func toggleShuffle() {
		isShuffle.toggle()
	}

	func seekToPercent(_ percent: Double) {
		guard
			let player,
			let playerItem,
			playerItem.status == .readyToPlay
		else {
			return
		}

		isSeeking = true
		let seconds = percent * currentItemDuration()!
		let time = CMTime(seconds: seconds, preferredTimescale: 1000)

		player.seek(to: time) { [weak self] isSuccess in
			guard let self else {
				return
			}

			isSeeking = false

			if !isSuccess {
				// TODO: Report error to the user here.
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
		let error = NSError.appError("Streaming error. Skipping to next track.")
		currentTrackPlaybackError(error)
	}

	@objc
	func currentTrackPlaybackStalledNotification(_ notification: Notification) {
		let error = NSError.appError("Streaming error. Skipping to next track.")
		currentTrackPlaybackError(error)
	}

	@objc
	func currentTrackNewAccessLogEntry(_ notification: Notification) {}

	@objc
	func currentTrackNewErrorLogEntry(_ notification: Notification) {
		print((notification.object as? AVPlayerItem)?.errorLog() ?? "")
	}

	func currentTrackPlaybackError(_ error: Error) {
		Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
		print(error)
		skipForward()
	}

	@objc
	func didAVPlayerTimeout() {
		guard let player else {
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
		let error = NSError.appError("Network error. Track took too long to load, skipping to next track.")
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

		if let playerItem {
			unsubscribeFromPlayerItem(playerItem)
		}

		let playerItem = AVPlayerItem(url: track.mediaURL())
		self.playerItem = playerItem

		subscribeToPlayerItem(playerItem)

		if
			let player,
			let progressObserver
		{
			player.removeTimeObserver(progressObserver)
		}

		timeoutTimer?.invalidate()
		timeoutTimer = Timer.scheduledTimer(timeInterval: timeoutSeconds, target: self, selector: #selector(didAVPlayerTimeout), userInfo: nil, repeats: false)

		player = AVPlayer(playerItem: playerItem)
		player?.volume = volume
		observeProgressUpdates()

		if currentDataSource != dataSource {
			currentDataSource = dataSource
		}
		currentTrack = track

		if let index = currentDataSource?.indexOfTrack(track) {
			recentlyPlayedTrackIndexes.append(index)
		}
	}

	func currentTrackChanged() {
		currentTrackListenLogged = false
		currentTrackListenScrobbled = false
	}

	fileprivate func volumeChanged() {
		guard let player else {
			return
		}

		player.volume = volume
	}

	fileprivate func observeProgressUpdates() {
		guard let player else {
			return
		}

		let thirdOfSecond = CMTimeMake(value: 1, timescale: 3)
		progressObserver = player.addPeriodicTimeObserver(forInterval: thirdOfSecond, queue: nil, using: progressUpdated) as AnyObject?
	}

	fileprivate func progressUpdated(_ time: CMTime) {
		guard
			!isSeeking,
			currentTrack != nil,
			let playerItem
		else {
			return
		}

		let progress = time.seconds
		let duration = playerItem.duration.seconds
		let userInfo: [String: Any] = [
			"progress": progress,
			"duration": duration,
			"track": currentTrack!
		]
		Notifications.post(name: Notifications.TrackProgressUpdated, object: self, userInfo: userInfo)

		if progress > 30, !currentTrackListenLogged {
			HypeMachineAPI.Requests.Me.postHistory(id: currentTrack!.id, position: 30) { _ in }
			currentTrackListenLogged = true
		} else if (progress / duration) > (2 / 3), !currentTrackListenScrobbled {
			HypeMachineAPI.Requests.Me.postHistory(id: currentTrack!.id, position: Int(progress)) { _ in }
			currentTrackListenScrobbled = true
		}
	}

	fileprivate func playerItemNotificationNamesAndSelectors() -> [String: Selector] {
		[
			Notification.Name.AVPlayerItemDidPlayToEndTime.rawValue: #selector(currentTrackFinishedPlayingNotification(_:)),
			Notification.Name.AVPlayerItemFailedToPlayToEndTime.rawValue: #selector(currentTrackCouldNotFinishPlayingNotification(_:)),
			Notification.Name.AVPlayerItemPlaybackStalled.rawValue: #selector(currentTrackPlaybackStalledNotification(_:)),
			Notification.Name.AVPlayerItemNewAccessLogEntry.rawValue: #selector(currentTrackNewAccessLogEntry(_:)),
			Notification.Name.AVPlayerItemNewErrorLogEntry.rawValue: #selector(currentTrackNewErrorLogEntry(_:))
		]
	}

	fileprivate func subscribeToPlayerItem(_ playerItem: AVPlayerItem) {
		for (name, selector) in playerItemNotificationNamesAndSelectors() {
			NotificationCenter.default.addObserver(self, selector: selector, name: Notification.Name(name), object: playerItem)
		}
	}

	fileprivate func unsubscribeFromPlayerItem(_ playerItem: AVPlayerItem) {
		for (name, _) in playerItemNotificationNamesAndSelectors() {
			NotificationCenter.default.removeObserver(self, name: Notification.Name(name), object: playerItem)
		}
	}

	fileprivate func findNextTrack() -> HypeMachineAPI.Track? {
		guard
			let currentTrack,
			let currentDataSource
		else {
			return nil
		}

		if
			isShuffle,
			!(currentDataSource is FavoriteTracksDataSource)
		{
			return nextShuffleTrack()
		}

		return currentDataSource.trackAfter(currentTrack)
	}

	fileprivate func nextShuffleTrack() -> HypeMachineAPI.Track? {
		guard let currentDataSource else {
			return nil
		}

		if recentlyPlayedTrackIndexes.count >= currentDataSource.tableContents!.count {
			recentlyPlayedTrackIndexes = []
		}

		var nextShuffleTrackIndex = Int.random(in: 0..<currentDataSource.tableContents!.count)

		while recentlyPlayedTrackIndexes.contains(nextShuffleTrackIndex) {
			nextShuffleTrackIndex = Int.random(in: 0..<currentDataSource.tableContents!.count)
		}

		return currentDataSource.trackAtIndex(nextShuffleTrackIndex)
	}
}
