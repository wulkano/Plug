import Cocoa
import HypeMachineAPI
import SnapKit

// swiftlint:disable:next final_class
class TrackTableCellView: IOSStyleTableCellView {
	let titleColor = NSColor.labelColor
	let artistColor = NSColor.secondaryLabelColor
	let disabledTitleColor = NSColor.tertiaryLabelColor
	let disabledArtistColor = NSColor.quaternaryLabelColor

	var playPauseButton: HoverToggleButton!
	var loveButton: TransparentButton!
	var loveContainerWidthConstraint: Constraint!
	var infoContainerWidthConstraint: Constraint!
	var progressSlider: NSSlider!
	var titleButton: HyperlinkButton!
	var artistButton: HyperlinkButton!
	var infoContainer: NSView!

	var showsLoveButton = true

	var dataSource: TracksDataSource!
	var trackInfoWindowController: NSWindowController?

	override var objectValue: Any? {
		didSet {
			objectValueChanged()
		}
	}

	var track: HypeMachineAPI.Track? {
		get { objectValue as? HypeMachineAPI.Track }
		set {
			objectValue = newValue
		}
	}

	var isMouseInside = false {
		didSet {
			mouseInsideChanged()
		}
	}

	var playState = PlayState.notPlaying {
		didSet {
			playStateChanged()
		}
	}

	var isTrackingProgress = false

	init() {
		super.init(frame: .zero)
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		Notifications.unsubscribeAll(observer: self)
	}

	func setup() {
		Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackPlaying(_:)), name: Notifications.TrackPlaying, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackPaused(_:)), name: Notifications.TrackPaused, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackLoved(_:)), name: Notifications.TrackLoved, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(TrackTableCellView.trackUnLoved(_:)), name: Notifications.TrackUnLoved, object: nil)
	}

	// Careful, since these cells are reused, any async calls
	// may return when the cell represents a different track.
	func objectValueChanged() {
		guard
			objectValue != nil,
			let track = track
		else {
			return
		}

		playState = currentPlayState
		updateTrackAvailability()
		updateTrackTitle()
		updateTrackArtist()
		isMouseInside = false
		loveButton.isSelected = track.isLoved
		progressSlider.doubleValue = 0
	}

	var currentPlayState: PlayState {
		guard AudioPlayer.shared.currentTrack == objectValue as? HypeMachineAPI.Track else {
			return .notPlaying
		}

		return AudioPlayer.shared.isPlaying ? .playing : .paused
	}

	func mouseInsideChanged() {
		updatePlayPauseButtonVisibility()
		updateLoveContainerSpacing()
		updateInfoContainerSpacing()
	}

	func playStateChanged() {
		updatePlayPauseButtonVisibility()
		updatePlayPauseButtonSelected()
		updateProgressSliderVisibility()
		trackOrUntrackProgress()
		updateTrackTitle()
		updateTrackArtist()
	}

	func updateTrackAvailability() {
		guard let track = track else {
			return
		}

		if track.audioUnavailable {
			titleButton.textColor = disabledTitleColor
			artistButton.textColor = disabledArtistColor
		} else {
			titleButton.textColor = titleColor
			artistButton.textColor = artistColor
		}
	}

	func updateTrackTitle() {
		guard let track = track else {
			return
		}

		titleButton.title = track.title
		switch playState {
		case .playing, .paused:
			titleButton.isSelected = true
		case .notPlaying:
			titleButton.isSelected = false
		}
	}

	func updateTrackArtist() {
		guard let track = track else {
			return
		}

		artistButton.title = track.artist
		switch playState {
		case .playing, .paused:
			artistButton.isSelected = true
		case .notPlaying:
			artistButton.isSelected = false
		}
	}

	func updatePlayPauseButtonVisibility() {
		guard let track = track else {
			return
		}

		if track.audioUnavailable {
			playPauseButton.isHidden = true
		} else if isMouseInside {
			playPauseButton.isHidden = false
		} else {
			switch playState {
			case .playing, .paused:
				playPauseButton.isHidden = false
			case .notPlaying:
				playPauseButton.isHidden = true
			}
		}
	}

	func updatePlayPauseButtonSelected() {
		switch playState {
		case .playing:
			playPauseButton.isSelected = true
		case .paused, .notPlaying:
			playPauseButton.isSelected = false
		}
	}

	func updateProgressSliderVisibility() {
		switch playState {
		case .playing, .paused:
			progressSlider.isHidden = false
		case .notPlaying:
			progressSlider.isHidden = true
		}
	}

	func trackOrUntrackProgress() {
		switch playState {
		case .playing, .paused:
			trackProgress()
		case .notPlaying:
			untrackProgress()
		}
	}

	func updateLoveContainerSpacing() {
		let openWidth = 38.0
		let closedWidth = 0.0

		if let track = track, isMouseInside || (track.isLoved && showsLoveButton) {
			loveContainerWidthConstraint.update(offset: openWidth)
		} else {
			loveContainerWidthConstraint.update(offset: closedWidth)
		}
	}

	func updateInfoContainerSpacing() {
		let openWidth = 30.0
		let closedWidth = 0.0

		if isMouseInside {
			infoContainerWidthConstraint.update(offset: openWidth)
		} else {
			infoContainerWidthConstraint.update(offset: closedWidth)
		}
	}

	func trackProgress() {
		if isTrackingProgress == false {
			Notifications.subscribe(observer: self, selector: #selector(progressUpdated(_:)), name: Notifications.TrackProgressUpdated, object: nil)
		}

		isTrackingProgress = true
	}

	func untrackProgress() {
		Notifications.unsubscribe(observer: self, name: Notifications.TrackProgressUpdated, object: self)
		isTrackingProgress = false
	}

	@objc
	func trackPlaying(_ notification: Notification) {
		guard objectValue != nil else {
			return
		}

		let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
		if notificationTrack == objectValue as? HypeMachineAPI.Track {
			playState = .playing
		} else {
			playState = .notPlaying
		}
	}

	@objc
	func trackPaused(_ notification: Notification) {
		guard objectValue != nil else {
			return
		}

		let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
		if notificationTrack == objectValue as? HypeMachineAPI.Track {
			playState = .paused
		}
	}

	@objc
	func trackLoved(_ notification: Notification) {
		guard objectValue != nil else {
			return
		}

		let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
		if notificationTrack == objectValue as? HypeMachineAPI.Track {
			track?.isLoved = true
			loveButton.isSelected = true
		}
		updateLoveContainerSpacing()
	}

	@objc
	func trackUnLoved(_ notification: Notification) {
		guard objectValue != nil else {
			return
		}

		let notificationTrack = notification.userInfo!["track"] as! HypeMachineAPI.Track
		if notificationTrack == objectValue as? HypeMachineAPI.Track {
			track?.isLoved = false
			loveButton.isSelected = false
		}
		updateLoveContainerSpacing()
	}

	// swiftlint:disable:next private_action
	@IBAction func playPauseButtonClicked(_ sender: HoverToggleButton) {
		guard let track = track else {
			return
		}

		Analytics.trackButtonClick("Playlist Play/Pause")
		switch playState {
		case .playing:
			AudioPlayer.shared.pause()
		case .paused, .notPlaying:
			AudioPlayer.shared.playNewTrack(track, dataSource: dataSource)
		}
	}

	// swiftlint:disable:next private_action
	@IBAction func infoButtonClicked(_ sender: TransparentButton) {
		Analytics.trackButtonClick("Playlist Info")

		if trackInfoWindowController == nil {
			let trackInfoStoryboard = NSStoryboard(name: "TrackInfo", bundle: nil)
			trackInfoWindowController = trackInfoStoryboard.instantiateInitialController() as? NSWindowController
			let trackInfoViewController = trackInfoWindowController!.window!.contentViewController!
			trackInfoViewController.representedObject = objectValue
		}

		trackInfoWindowController!.showWindow(self)
	}

	// swiftlint:disable:next private_action
	@IBAction func loveButtonClicked(_ sender: TransparentButton) {
		guard let track = track else {
			return
		}

		Analytics.trackButtonClick("Playlist Heart")
		let oldLovedValue = track.isLoved
		let newLovedValue = !oldLovedValue

		changeTrackLovedValueTo(newLovedValue)

		HypeMachineAPI.Requests.Me.toggleTrackFavorite(id: track.id) { [weak self] response in
			guard let self = self else {
				return
			}

			switch response.result {
			case .success(let favorited):
				if favorited != newLovedValue {
					self.changeTrackLovedValueTo(favorited)
				}
			case .failure(let error):
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)
				self.changeTrackLovedValueTo(oldLovedValue)
			}
		}
	}

	// swiftlint:disable:next private_action
	@IBAction func progressSliderDragged(_ sender: NSSlider) {
		AudioPlayer.shared.seekToPercent(sender.doubleValue)
	}

	// swiftlint:disable:next private_action
	@IBAction func artistButtonClicked(_ sender: NSButton) {
		guard let track = track else {
			return
		}

		let viewController = TracksViewController(type: .loveCount, title: track.artist, analyticsViewName: "MainWindow/SingleArtist")
		viewController.dataSource = ArtistTracksDataSource(viewController: viewController, artistName: track.artist)
		NavigationController.shared!.pushViewController(viewController, animated: true)
	}

	// swiftlint:disable:next private_action
	@IBAction func titleButtonClicked(_ sender: NSButton) {
		guard let track = track else {
			return
		}

		print("Track title clicked: \(track.title)")
	}

	func changeTrackLovedValueTo(_ isLoved: Bool) {
		guard let track = track else {
			return
		}

		if isLoved {
			Notifications.post(name: Notifications.TrackLoved, object: self, userInfo: ["track" as NSObject: track])
		} else {
			Notifications.post(name: Notifications.TrackUnLoved, object: self, userInfo: ["track" as NSObject: track])
		}
	}

	@objc
	func progressUpdated(_ notification: Notification) {
		let progress = (notification.userInfo!["progress"] as! NSNumber).doubleValue
		let duration = (notification.userInfo!["duration"] as! NSNumber).doubleValue
		progressSlider.doubleValue = progress / duration
	}

	enum PlayState {
		case playing
		case paused
		case notPlaying
	}
}
