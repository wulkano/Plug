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
        
        contextMenu.addItem(NSMenuItem(title: "Copy Hype Machine Link", action: "copyHypeMachineLinkClicked:", keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Open Hype Machine Link in Browser", action: "openHypeMachineLinkInBrowserClicked:", keyEquivalent: ""))
        
        contextMenu.addItem(NSMenuItem.separatorItem())
        contextMenu.addItem(NSMenuItem(title: "Copy SoundCloud Link", action: "copySoundCloudLinkClicked:", keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Open SoundCloud Link in Browser", action: "openSoundCloudLinkInBrowser:", keyEquivalent: ""))
        
        contextMenu.addItem(NSMenuItem.separatorItem())
        contextMenu.addItem(NSMenuItem(title: "Share to Facebook", action: "shareToFacebookClicked:", keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Share to Twitter", action: "shareToTwitterClicked:", keyEquivalent: ""))
        contextMenu.addItem(NSMenuItem(title: "Share to Messages", action: "shareToMessagesClicked:", keyEquivalent: ""))
        
        for item in contextMenu.itemArray as! [NSMenuItem] {
            item.target = self
        }
    }
    
    // MARK: Actions
    
    func copyHypeMachineLinkClicked(sender: AnyObject) {
        let hypeMachineURL = track.hypeMachineURL().absoluteString!
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().setString(hypeMachineURL, forType: NSStringPboardType)
    }
    
    func openHypeMachineLinkInBrowserClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(track.hypeMachineURL())
    }
    
    func copySoundCloudLinkClicked(sender: AnyObject) {
        let url = track.mediaURL()
        
        SoundCloudPermalinkFinder(mediaURL: url,
            success: { (trackURL: NSURL) in
                NSPasteboard.generalPasteboard().clearContents()
                NSPasteboard.generalPasteboard().setString(trackURL.absoluteString!, forType: NSStringPboardType)
            }, failure: { error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                println(error)
        })
    }
    
    func openSoundCloudLinkInBrowser(sender: AnyObject) {
        let url = track.mediaURL()
        
        SoundCloudPermalinkFinder(mediaURL: url,
            success: { (trackURL: NSURL) in
                NSWorkspace.sharedWorkspace().openURL(trackURL)
                return
            }, failure: { error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                println(error)
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
        NSURLConnection(request: request, delegate: self)
    }
    
    func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse response: NSURLResponse?) -> NSURLRequest? {
        println(request.URL!.host!)
        
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
        let prefix = "http://api.soundcloud.com/tracks/"
        let suffix = "/stream"
        return url.absoluteString!.getSubstringBetweenPrefix(prefix, andSuffix: suffix)
    }
    
    func requestPermalinkForTrackID(trackID: String) {
        SoundCloudAPI.Tracks.permalink(trackID) {
            (permalink, error) in
            
            if permalink != nil {
                self.success(trackURL: permalink!)
                return
            } else {
                self.failure(error: error!)
            }
        }
    }
}
