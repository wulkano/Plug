//
//  Track.swift
//  Plug
//
//  Created by Alex Marchant on 6/6/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

class TrackBack: NSObject {
    
    // Hype Machine Properties
    let mediaID: String
    let artist: String
    let title: String
    let datePosted: Int
    let siteID: Int
    let siteName: String
    let postURL: NSURL
    let postID: Int
    let lovedCount: Int
    let postedCount: Int
    let thumbURL: NSURL?
    let thumbURLMedium: NSURL?
    let thumbURLLarge: NSURL?
    let time: Int
    let trackDescription: String
    let iTunesLink: NSURL?
    let rank: Int?
    var pubAudioUnavail: Bool = false
    let viaUser: String?

    // Plug Properties
    var mediaLinkRetry: NSURL?
    var type: String?
    var favorite: Bool = false
    var listenLogged: Bool = false
    var scrobbleLogged: Bool = false
    
    // Generated Properties
    var artistAndTitle : NSAttributedString {
        let text = "\(artist) - \(title)"
        var attrText = NSMutableAttributedString(string: text)
        
        // Ranges
        let artistRange = NSMakeRange(0, countElements(artist))
        let separatorRange = NSMakeRange(countElements(artist), 3)
        let titleRange = NSMakeRange(countElements(artist) + 3, countElements(title))
        let wholeRange = NSMakeRange(0, countElements(text))
        
        // Colors
        let artistColor = NSColor(red256: 108, green256: 117, blue256: 122)
        let separatorColor = NSColor(red256: 62, green256: 62, blue256: 67)
        let titleColor = NSColor(red256: 28, green256: 28, blue256: 31)
        
        // Fonts
        let artistFont = NSFont(name: "Helvetica Neue Medium", size:12)
        let separatorFont = NSFont(name: "Helvetica Neue", size:12)
        let titleFont = NSFont(name: "Helvetica Neue Bold", size:12)
        
        // Artist
        attrText.addAttribute(NSFontAttributeName, value: artistFont, range: artistRange)
        attrText.addAttribute(NSForegroundColorAttributeName, value: artistColor, range: artistRange)
        
        // Separator
        attrText.addAttribute(NSFontAttributeName, value: separatorFont, range: separatorRange)
        attrText.addAttribute(NSForegroundColorAttributeName, value: separatorColor, range: separatorRange)
        
        // Title
        attrText.addAttribute(NSFontAttributeName, value: titleFont, range: titleRange)
        attrText.addAttribute(NSForegroundColorAttributeName, value: titleColor, range: titleRange)
        
        // Center text & cut off with elipsis
        var paraStyle = NSMutableParagraphStyle()
        paraStyle.alignment = NSTextAlignment.CenterTextAlignment
        paraStyle.lineBreakMode = NSLineBreakMode.ByClipping
        
        attrText.addAttribute(NSParagraphStyleAttributeName, value: paraStyle, range: wholeRange)
        
        return attrText
    }
    var mediaLink : NSURL {
        var mediaLinkString = "https://hypem.com/serve/public/\(mediaID)?key=\(ApiKey)"
        return NSURL(string: mediaLinkString)
    }
    var webURL : NSURL {
        var webURLString = "http://hypem.com/track/\(mediaID)"
        return NSURL(string: webURLString)
    }
    
    init(JSON json: NSDictionary) {
        mediaID = DictHelper.stringValueOrPlaceholder(json["itemid"], placeholder: "N/A")
        artist = DictHelper.stringValueOrPlaceholder(json["artist"], placeholder: "N/A")
        title = DictHelper.stringValueOrPlaceholder(json["title"], placeholder: "N/A")
        datePosted = DictHelper.integerValueOrPlaceholder(json["dateposted"], placeholder: 0)
        siteID = DictHelper.integerValueOrPlaceholder(json["siteid"], placeholder: 0)
        siteName = DictHelper.stringValueOrPlaceholder(json["sitename"], placeholder: "N/A")
        postURL = DictHelper.urlValueOrPlaceholder(json["posturl"], placeholder: "http://hypem.com/not-found")
        postID = DictHelper.integerValueOrPlaceholder(json["postid"], placeholder: 0)
        lovedCount = DictHelper.integerValueOrPlaceholder(json["loved_count"], placeholder: 0)
        postedCount = DictHelper.integerValueOrPlaceholder(json["posted_count"], placeholder: 0)
        thumbURL = DictHelper.urlValueOrNil(json["thumb_url"])
        thumbURLMedium = DictHelper.urlValueOrNil(json["thumb_url_medium"])
        thumbURLLarge = DictHelper.urlValueOrNil(json["thumb_url_large"])
        time = DictHelper.integerValueOrPlaceholder(json["time"], placeholder: 0)
        trackDescription = DictHelper.stringValueOrPlaceholder(json["description"], placeholder: "N/A")
        iTunesLink = DictHelper.urlValueOrNil(json["itunes_link"])
        favorite = json["ts_loved_me"] ? true : false
        rank = DictHelper.integerValueOrNil(json["rank"])
        pubAudioUnavail = DictHelper.boolValueOrPlaceholder(json["pub_audio_unavail"], placeholder: false)
        viaUser = DictHelper.stringValueOrNil(json["via_user"])
        
        super.init()
    }
    
    func description() -> String {
        return "\(artist) - \(title)"
    }
    
    func thumbHelper() -> NSURL {
        var hypePlaceholderImageUrls = [
            "http://static-ak.hypem.net/images/albumart0.gif",
            "http://static-ak.hypem.net/images/albumart1.gif",
            "http://static-ak.hypem.net/images/albumart2.gif",
            "http://static-ak.hypem.net/images/albumart3.gif",
            "http://static-ak.hypem.net/images/albumart4.gif",
            ""
        ]
        if thumbURLLarge && !hypePlaceholderImageUrls.contains(thumbURLLarge!.absoluteString)  {
            return thumbURLLarge!
        } else if thumbURLMedium && !hypePlaceholderImageUrls.contains(thumbURLMedium!.absoluteString) {
            return thumbURLMedium!
        } else if thumbURL && !hypePlaceholderImageUrls.contains(thumbURL!.absoluteString) {
            return thumbURL!
        } else {
            return NSURL(string: "http://static-ak.hypem.net/images/albumart0.gif")
        }
    }
    
    func formattedLovedCount() -> String {
        if lovedCount > 1000 {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.format = "####.#K"
            let abbrLovedCount = Double(lovedCount) / 1000
            return numberFormatter.stringFromNumber(abbrLovedCount)
        } else {
            return String(lovedCount)
        }
    }
}
