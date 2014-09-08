//
//  TrackContextMenuController.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TrackContextMenuController: NSViewController, NSSharingServiceDelegate {
    @IBOutlet var contextMenu: NSMenu!
    
    var representedTrack: Track {
        return representedObject as Track
    }
    
    @IBAction func copyHypeMachineLinkClicked(sender: AnyObject) {
        let hypeMachineURL = representedTrack.hypeMachineURL().absoluteString!
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().setString(hypeMachineURL, forType: NSStringPboardType)
    }
    
    @IBAction func openInBrowserClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(representedTrack.hypeMachineURL())
    }
    
    @IBAction func findTrackOnSoundcloudClicked(sender: AnyObject) {
        let artistAndTitle = "\(representedTrack.artist), \(representedTrack.title)"
        let escapedArtistAndTitle = artistAndTitle.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: "https://soundcloud.com/search/sounds?q=\(escapedArtistAndTitle)")
        NSWorkspace.sharedWorkspace().openURL(url)
    }
    
    @IBAction func findArtistOnSoundcloudClicked(sender: AnyObject) {
        let escapedArtist = representedTrack.artist.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let url = NSURL(string: "https://soundcloud.com/search/people?q=\(escapedArtist)")
        NSWorkspace.sharedWorkspace().openURL(url)
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
        let sharingService = NSSharingService(named: name)
        sharingService.delegate = self
        sharingService.performWithItems(shareContents)
    }
    
    private func shareMessage() -> String {
        return "\(representedTrack.title) - \(representedTrack.artist) \(representedTrack.hypeMachineURL())\nvia @plugformac"
    }
}
