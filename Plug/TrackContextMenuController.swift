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
    @IBOutlet var contextMenu: NSMenu!
    
    var representedTrack: HypeMachineAPI.Track {
        return representedObject as! HypeMachineAPI.Track
    }
    
    @IBAction func copyHypeMachineLinkClicked(sender: AnyObject) {
        let hypeMachineURL = representedTrack.hypeMachineURL().absoluteString!
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().setString(hypeMachineURL, forType: NSStringPboardType)
    }
    
    @IBAction func openHypeMachineLinkInBrowserClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(representedTrack.hypeMachineURL())
    }
    
    @IBAction func copySoundCloudLinkClicked(sender: AnyObject) {
        let url = representedTrack.mediaURL()
        
        SoundCloudPermalinkFinder(mediaURL: url,
            success: { (trackURL: NSURL) in
                NSPasteboard.generalPasteboard().clearContents()
                NSPasteboard.generalPasteboard().setString(trackURL.absoluteString!, forType: NSStringPboardType)
            }, failure: { error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                println(error)
        })
    }
    
    @IBAction func openSoundCloudLinkInBrowser(sender: AnyObject) {
        let url = representedTrack.mediaURL()
        
        SoundCloudPermalinkFinder(mediaURL: url,
            success: { (trackURL: NSURL) in
                NSWorkspace.sharedWorkspace().openURL(trackURL)
                return
            }, failure: { error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                println(error)
        })
    }
    
    @IBAction func shareToFacebookClicked(sender: AnyObject) {
        shareTrackWithServiceNamed(NSSharingServiceNamePostOnFacebook)
    }
    
    @IBAction func shareToTwitterClicked(sender: AnyObject) {
        shareTrackWithServiceNamed(NSSharingServiceNamePostOnTwitter)
    }
    
    @IBAction func shareToMessagesClicked(sender: AnyObject) {
        shareTrackWithServiceNamed(NSSharingServiceNameComposeMessage)
    }
    
    private func shareTrackWithServiceNamed(name: String) {
        let shareContents = [shareMessage()]
        let sharingService = NSSharingService(named: name)!
        sharingService.delegate = self
        sharingService.performWithItems(shareContents)
    }
    
    private func shareMessage() -> String {
        return "\(representedTrack.title) - \(representedTrack.artist) \(representedTrack.hypeMachineURL())\nvia @plugformac"
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
