//
//  SingleBlogViewFormatter.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class SingleBlogViewFormatter: NSFormatter {
    var colorArt: SLColorArt!

    func attributedBlogDetails(blog: HypeMachineAPI.Blog, colorArt: SLColorArt) -> NSAttributedString {
        self.colorArt = colorArt
        
        let formattedFollowersCount = formattedCount(blog.followerCountNum)
        let formattedFollowersLabel = formattedLabel(" Followers  ")
        let formattedTracksCount = formattedCount(blog.trackCountNum)
        let formattedTracksLabel = formattedLabel(" Tracks")
        
        let blogDetails = NSMutableAttributedString()
        blogDetails.appendAttributedString(formattedFollowersCount)
        blogDetails.appendAttributedString(formattedFollowersLabel)
        blogDetails.appendAttributedString(formattedTracksCount)
        blogDetails.appendAttributedString(formattedTracksLabel)
        
        return blogDetails
    }
    
    func formattedCount(count: NSNumber) -> NSAttributedString {
        let countString = LovedCountFormatter().stringForObjectValue(count)!
        return NSAttributedString(string: countString, attributes: countAttributes())
    }
    
    func formattedLabel(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: labelAttributes())
    }
    
    func countAttributes() -> [String: AnyObject] {
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = getCountColor()
        attributes[NSFontAttributeName] = getFont()
        return attributes
    }
    
    func labelAttributes() -> [String: AnyObject] {
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = getLabelColor()
        attributes[NSFontAttributeName] = getFont()
        return attributes
    }
    
    func getCountColor() -> NSColor {
        
        if colorArt.primaryColor != nil {
            return colorArt.primaryColor
        } else if colorArt.secondaryColor != nil {
            return colorArt.secondaryColor
        } else if colorArt.detailColor != nil {
            return colorArt.detailColor
        } else {
            return NSColor.blackColor()
        }
    }
    
    func getLabelColor() -> NSColor {
        
        if colorArt.secondaryColor != nil {
            return colorArt.secondaryColor
        } else if colorArt.detailColor != nil {
            return colorArt.detailColor
        } else if colorArt.primaryColor != nil {
            return colorArt.primaryColor
        } else {
            return NSColor.blackColor()
        }
    }
    
    func getFont() -> NSFont {
        return NSFont(name: "HelveticaNeue-Medium", size: 13)!
    }
}
