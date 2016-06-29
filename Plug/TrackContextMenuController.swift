//
//  TrackContextMenuController.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
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
        
        if track.mediaType == "soundcloud"  {
            contextMenu.addItem(NSMenuItem.separatorItem())
            contextMenu.addItem(NSMenuItem(title: "Copy SoundCloud Link", action: #selector(TrackContextMenuController.copySoundCloudLinkClicked(_:)), keyEquivalent: ""))
            contextMenu.addItem(NSMenuItem(title: "Open SoundCloud Link in Browser", action: #selector(TrackContextMenuController.openSoundCloudLinkInBrowser(_:)), keyEquivalent: ""))
        }
        
        contextMenu.addItem(NSMenuItem.separatorItem())
        contextMenu.addItem(NSMenuItem(title: "Share to Facebook", action: #selector(TrackContextMenuController.shareToFacebookClicked(_:)), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Share to Twitter", action: #selector(TrackContextMenuController.shareToTwitterClicked(_:)), keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Share to Messages", action: #selector(TrackContextMenuController.shareToMessagesClicked(_:)), keyEquivalent: ""))
        
        for item in contextMenu.itemArray {
            item.target = self
        }
    }
    
    // MARK: Actions
    
    func copyHypeMachineLinkClicked(sender: AnyObject) {
        let hypeMachineURL = track.hypeMachineURL().absoluteString
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().setString(hypeMachineURL, forType: NSStringPboardType)
    }
    
    func openHypeMachineLinkInBrowserClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(track.hypeMachineURL())
    }
    
    func copySoundCloudLinkClicked(sender: AnyObject) {
        let url = track.mediaURL()
        
        _ = SoundCloudPermalinkFinder(mediaURL: url,
            success: { (trackURL: NSURL) in
                NSPasteboard.generalPasteboard().clearContents()
                NSPasteboard.generalPasteboard().setString(trackURL.absoluteString, forType: NSStringPboardType)
            }, failure: { error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                print(error)
        })
    }
    
    func openSoundCloudLinkInBrowser(sender: AnyObject) {
        let url = track.mediaURL()
        
        _ = SoundCloudPermalinkFinder(mediaURL: url,
            success: { (trackURL: NSURL) in
                NSWorkspace.sharedWorkspace().openURL(trackURL)
                return
            }, failure: { error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                print(error)
        })
    }
    
    func shareToFacebookClicked(sender: AnyObject) {
        shareTrackWithServiceNamed(NSSharingServiceNamePostOnFacebook)
    }
    
    func shareToTwitterClicked(sender: AnyObject) {
        shareTrackWithServiceNamed(NSSharingServiceNamePostOnTwitter)
    }
    
    func shareToMessagesClicked(sender: AnyObject) {
        shareTrackWithServiceNamed(NSSharingServiceNameComposeMessage)
    }
    
    // MARK: Private
    
    private func shareTrackWithServiceNamed(name: String) {
        let shareContents = [shareMessage()]
        let sharingService = NSSharingService(named: name)!
        sharingService.delegate = self
        sharingService.performWithItems(shareContents)
    }
    
    private func shareMessage() -> String {
        return "\(track.title) - \(track.artist) \(track.hypeMachineURL())\nvia @plugformac"
    }
    

}

class SoundCloudPermalinkFinder: NSObject, NSURLConnectionDataDelegate {
    var success: (trackURL: NSURL)->()
    var failure: (error: NSError)->()
    
    init(mediaURL: NSURL, success: (trackURL: NSURL)->(), failure: (error: NSError)->()) {
        self.success = success
        self.failure = failure
        super.init()
        
        let request = NSURLRequest(URL: mediaURL)
        _ = NSURLConnection(request: request, delegate: self)
    }
    
    func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?) -> NSURLRequest? {
        print(request.URL!.host!)
        
        if request.URL!.host! == "api.soundcloud.com" {
            
            connection.cancel()
            
            if let trackID = parseTrackIDFromURL(request.URL!) {
                requestPermalinkForTrackID(trackID)
            } else {
                let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find SoundCloud link for this track."])
                failure(error: error)
            }
        }
        
        return request
    }
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        connection.cancel()
        let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find SoundCloud link for this track."])
        failure(error: error)
    }
    
    func parseTrackIDFromURL(url: NSURL) -> String? {
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
    
    func requestPermalinkForTrackID(trackID: String) {
        SoundCloudAPI.Tracks.permalink(trackID) { result in
            switch result {
            case .Success(let permalink):
                self.success(trackURL: permalink)
            case .Failure(_, let error):
                self.failure(error: error as NSError)
            }
        }
    }
}
