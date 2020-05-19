//
//	TrackContextMenuController.swift
//	Plug
//
//	Created by Alex Marchant on 9/7/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class TrackContextMenuController: NSViewController, NSSharingServiceDelegate {
	let track: HypeMachineAPI.Track
	var contextMenu: NSMenu!

	init?(track: HypeMachineAPI.Track) {
		self.track = track
		super.init(nibName: nil, bundle: nil)
		setupViews()
	}

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
		contextMenu.addItem(NSMenuItem(title: "Share to Facebook", action: #selector(TrackContextMenuController.shareToFacebookClicked(_:)), keyEquivalent: ""))
		contextMenu.addItem(NSMenuItem(title: "Share to Twitter", action: #selector(TrackContextMenuController.shareToTwitterClicked(_:)), keyEquivalent: ""))
		contextMenu.addItem(NSMenuItem(title: "Share to Messages", action: #selector(TrackContextMenuController.shareToMessagesClicked(_:)), keyEquivalent: ""))

		for item in contextMenu.items {
			item.target = self
		}
	}

	// MARK: Actions

	@objc func copyHypeMachineLinkClicked(_ sender: AnyObject) {
		let hypeMachineURL = track.hypeMachineURL().absoluteString
		NSPasteboard.general.clearContents()
		NSPasteboard.general.setString(hypeMachineURL, forType: .string)
	}

	@objc func openHypeMachineLinkInBrowserClicked(_ sender: AnyObject) {
		NSWorkspace.shared.open(track.hypeMachineURL())
	}

	@objc func copySoundCloudLinkClicked(_ sender: AnyObject) {
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

	@objc func openSoundCloudLinkInBrowser(_ sender: AnyObject) {
		let url = track.mediaURL()

		_ = SoundCloudPermalinkFinder(
			mediaURL: url,
			success: { (trackURL: URL) in
				NSWorkspace.shared.open(trackURL)
				return
			},
			failure: { error in
				Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
				print(error)
			}
		)
	}

	@objc func shareToFacebookClicked(_ sender: AnyObject) {
		shareTrackWithServiceNamed(NSSharingService.Name.postOnFacebook.rawValue)
	}

	@objc func shareToTwitterClicked(_ sender: AnyObject) {
		shareTrackWithServiceNamed(NSSharingService.Name.postOnTwitter.rawValue)
	}

	@objc func shareToMessagesClicked(_ sender: AnyObject) {
		shareTrackWithServiceNamed(NSSharingService.Name.composeMessage.rawValue)
	}

	// MARK: Private

	fileprivate func shareTrackWithServiceNamed(_ name: String) {
		let shareContents = [shareMessage()]
		let sharingService = NSSharingService(named: NSSharingService.Name(rawValue: name))!
		sharingService.delegate = self
		sharingService.perform(withItems: shareContents)
	}

	fileprivate func shareMessage() -> String {
		"\(track.title) - \(track.artist) \(track.hypeMachineURL())\nvia @plugformac"
	}
}

class SoundCloudPermalinkFinder: NSObject, NSURLConnectionDataDelegate {
	var success: (_ trackURL: URL) -> Void
	var failure: (_ error: NSError) -> Void

	init(mediaURL: URL, success: @escaping (_ trackURL: URL) -> Void, failure: @escaping (_ error: NSError) -> Void) {
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
				let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find SoundCloud link for this track."])
				failure(error)
			}
		}

		return request
	}

	func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
		connection.cancel()
		let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find SoundCloud link for this track."])
		failure(error)
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
		SoundCloudAPI.Tracks.permalink(trackID) { response in
			switch response.result {
			case let .success(permalink):
				self.success(permalink)
			case let .failure(error):
				self.failure(error as NSError)
			}
		}
	}
}
