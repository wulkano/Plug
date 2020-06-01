import Cocoa
import HypeMachineAPI
import Alamofire

final class TrackInfoViewController: NSViewController, TagContainerViewDelegate, PostInfoTextFieldDelegate {
	@IBOutlet var titleTextField: VibrantTextField!
	@IBOutlet var artistTextField: VibrantTextField!
	@IBOutlet var loveCountTextField: VibrantTextField!
	@IBOutlet var albumArt: NSImageView!
	@IBOutlet var postedCountTextField: NSTextField!
	@IBOutlet var postInfoTextField: PostInfoTextField!
	@IBOutlet var loveButton: TransparentButton!

	override var representedObject: Any! {
		didSet {
			representedObjectChanged()
		}
	}

	var representedTrack: HypeMachineAPI.Track { representedObject as! HypeMachineAPI.Track }

	override func viewDidLoad() {
		super.viewDidLoad()

		Notifications.subscribe(observer: self, selector: #selector(TrackInfoViewController.trackLoved(_:)), name: Notifications.TrackLoved, object: nil)
		Notifications.subscribe(observer: self, selector: #selector(TrackInfoViewController.trackUnLoved(_:)), name: Notifications.TrackUnLoved, object: nil)
		postInfoTextField.postInfoDelegate = self

		Analytics.trackView("TrackInfoWindow")
	}

	@IBAction private func closeButtonClicked(_ sender: NSButton) {
		view.window!.close()
	}

	@IBAction private func loveButtonClicked(_ sender: NSButton) {
		Analytics.trackButtonClick("Track Info Heart")

		let oldLovedValue = representedTrack.loved
		let newLovedValue = !oldLovedValue

		changeTrackLovedValueTo(newLovedValue)

		HypeMachineAPI.Requests.Me.toggleTrackFavorite(id: representedTrack.id) { response in
			switch response.result {
			case let .success(favorited):
				if favorited != newLovedValue {
					self.changeTrackLovedValueTo(favorited)
				}
			case let .failure(error):
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
				print(error)
				self.changeTrackLovedValueTo(oldLovedValue)
			}
		}
	}

	func postInfoTextFieldClicked(_ sender: AnyObject) {
		Analytics.trackButtonClick("Track Info Blog Description")

		NSWorkspace.shared.open(representedTrack.postURL)
	}

	func tagButtonClicked(_ tag: HypeMachineAPI.Tag) {
		loadSingleTagView(tag)
	}

	func loadSingleTagView(_ tag: HypeMachineAPI.Tag) {
		let viewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "TracksViewController") as! TracksViewController
		viewController.title = tag.name
		NavigationController.shared!.pushViewController(viewController, animated: true)
		viewController.dataSource = TagTracksDataSource(viewController: viewController, tagName: tag.name)
	}

	@IBAction private func downloadITunesButtonClicked(_ sender: NSButton) {
		Analytics.trackButtonClick("Track Info Download iTunes")

		NSWorkspace.shared.open(representedTrack.iTunesURL)
	}

	@IBAction private func seeMoreButtonClicked(_ sender: NSButton) {
		Analytics.trackButtonClick("Track Info See More")

		NSWorkspace.shared.open(representedTrack.hypeMachineURL())
	}

	@objc
	func trackLoved(_ notification: Notification) {
		let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
		if track == representedObject as? HypeMachineAPI.Track {
			representedObject = track
			updateLoveButton()
		}
	}

	@objc
	func trackUnLoved(_ notification: Notification) {
		let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
		if track == representedTrack {
			representedObject = track
			updateLoveButton()
		}
	}

	func changeTrackLovedValueTo(_ loved: Bool) {
		var newTrack = representedTrack
		newTrack.loved = loved
		representedObject = newTrack

		if loved {
			Notifications.post(name: Notifications.TrackLoved, object: self, userInfo: ["track" as NSObject: representedTrack])
		} else {
			Notifications.post(name: Notifications.TrackUnLoved, object: self, userInfo: ["track" as NSObject: representedTrack])
		}
	}

	func representedObjectChanged() {
		updateTitle()
		updateArtist()
		updateLoveCount()
		updateAlbumArt()
		updatePostedCount()
		updatePostInfo()
		updateLoveButton()
	}

	func updateTitle() {
		titleTextField.stringValue = representedTrack.title
	}

	func updateArtist() {
		artistTextField.stringValue = representedTrack.artist
	}

	func updateLoveCount() {
		loveCountTextField.objectValue = representedTrack.lovedCountNum
	}

	func updateAlbumArt() {
		let url = representedTrack.thumbURL(preferedSize: .medium)

		Alamofire.request(url).validate().responseImage { response in
			switch response.result {
			case let .success(image):
				self.albumArt.image = image
			case let .failure(error):
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error as NSError])
				print(error as NSError)
			}
		}
	}

	func updatePostedCount() {
		postedCountTextField.stringValue = "Posted by \(representedTrack.postedCount) Blogs"
	}

	func updatePostInfo() {
		let postInfoAttributedString = PostInfoFormatter().attributedStringForPostInfo(representedTrack)
		postInfoTextField.attributedStringValue = postInfoAttributedString
	}

	func updateLoveButton() {
		loveButton.isSelected = representedTrack.loved
	}
}
