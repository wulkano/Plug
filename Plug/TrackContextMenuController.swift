import Cocoa
import HypeMachineAPI

final class TrackContextMenuController: NSViewController, NSSharingServiceDelegate {
	let track: HypeMachineAPI.Track
	var contextMenu: NSMenu!

	init?(track: HypeMachineAPI.Track) {
		self.track = track
		super.init(nibName: nil, bundle: nil)
		setupViews()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupViews() {
		contextMenu = NSMenu()

		contextMenu.addItem(NSMenuItem(title: "Copy Hype Machine Link", action: #selector(TrackContextMenuController.copyHypeMachineLinkClicked(_:)), keyEquivalent: ""))
		contextMenu.addItem(NSMenuItem(title: "Open Hype Machine Link in Browser", action: #selector(TrackContextMenuController.openHypeMachineLinkInBrowserClicked(_:)), keyEquivalent: ""))

		if track.mediaType == "soundcloud" {
			contextMenu.addItem(NSMenuItem.separator())
			contextMenu.addItem(NSMenuItem(title: "Copy SoundCloud Link", action: #selector(TrackContextMenuController.copySoundCloudLinkClicked(_:)), keyEquivalent: ""))
			contextMenu.addItem(NSMenuItem(title: "Open SoundCloud Link in Browser", action: #selector(TrackContextMenuController.openSoundCloudLinkInBrowser(_:)), keyEquivalent: ""))
		}

		contextMenu.addItem(NSMenuItem.separator())

		let shareMenu = NSMenuItem(title: "Share", action: nil, keyEquivalent: "")
			.withSubmenu { menu in
				let shareItems = [shareMessage()]

				for service in NSSharingService.sharingServices(forItems: shareItems) {
					let menuItem = NSMenuItem(title: service.title, action: nil, keyEquivalent: "")
					menuItem.target = self
					menuItem.image = service.image

					menuItem.onAction { _ in
						service.perform(withItems: shareItems)
					}

					menu.addItem(menuItem)
				}

				return menu
			}
		contextMenu.addItem(shareMenu)

		for item in contextMenu.items {
			item.target = self
		}
	}

	// MARK: Actions

	@objc
	func copyHypeMachineLinkClicked(_ sender: AnyObject) {
		let hypeMachineURL = track.hypeMachineURL().absoluteString
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString(hypeMachineURL, forType: .string)
	}

	@objc
	func openHypeMachineLinkInBrowserClicked(_ sender: AnyObject) {
		track.hypeMachineURL().open()
	}

	@objc
	func copySoundCloudLinkClicked(_ sender: AnyObject) {
		let url = track.mediaURL()

		_ = SoundCloudPermalinkFinder(
			mediaURL: url,
			success: { (trackURL: URL) in
				NSPasteboard.general.clearContents()
				NSPasteboard.general.setString(trackURL.absoluteString, forType: .string)
			},
			failure: { error in
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)
			}
		)
	}

	@objc
	func openSoundCloudLinkInBrowser(_ sender: AnyObject) {
		let url = track.mediaURL()

		_ = SoundCloudPermalinkFinder(
			mediaURL: url,
			success: { trackURL in
				trackURL.open()
				return
			},
			failure: { error in
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)
			}
		)
	}

	// MARK: Private

	fileprivate func shareMessage() -> String {
		"\(track.title) - \(track.artist) \(track.hypeMachineURL())\nvia @plugformac"
	}
}

final class SoundCloudPermalinkFinder: NSObject, NSURLConnectionDataDelegate {
	let success: (_ trackURL: URL) -> Void
	let failure: (_ error: Error) -> Void

	init(
		mediaURL: URL,
		success: @escaping (_ trackURL: URL) -> Void,
		failure: @escaping (_ error: Error) -> Void
	) {
		self.success = success
		self.failure = failure
		super.init()

		let request = URLRequest(url: mediaURL)
		_ = NSURLConnection(request: request, delegate: self)
	}

	func connection(_ connection: NSURLConnection, willSend request: URLRequest, redirectResponse response: URLResponse?) -> URLRequest? {
		print(request.url!.host!)

		if request.url!.host! == "api.soundcloud.com" {
			connection.cancel()

			if let trackID = parseTrackIDFromURL(request.url!) {
				requestPermalinkForTrackID(trackID)
			} else {
				failure(NSError.appError("Can't find SoundCloud link for this track."))
			}
		}

		return request
	}

	func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
		connection.cancel()
		failure(NSError.appError("Can't find SoundCloud link for this track."))
	}

	func parseTrackIDFromURL(_ url: URL) -> String? {
		let httpsPrefix = "https://api.soundcloud.com/tracks/"
		let httpPrefix = "http://api.soundcloud.com/tracks/"
		let suffix = "/stream"

		if let trackID = url.absoluteString.getSubstringBetweenPrefix(httpsPrefix, andSuffix: suffix) {
			return trackID
		} else if let trackID = url.absoluteString.getSubstringBetweenPrefix(httpPrefix, andSuffix: suffix) {
			return trackID
		} else {
			return nil
		}
	}

	func requestPermalinkForTrackID(_ trackID: String) {
		SoundCloudAPI.Tracks.permalink(trackID) { [weak self] response in
			guard let self = self else {
				return
			}

			switch response.result {
			case .success(let permalink):
				self.success(permalink)
			case .failure(let error):
				self.failure(error)
			}
		}
	}
}
