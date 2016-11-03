//
//  SingleBlogViewFormatter.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class SingleBlogViewFormatter: Formatter {
    var colorArt: SLColorArt!

    func attributedBlogDetails(_ blog: HypeMachineAPI.Blog, colorArt: SLColorArt) -> NSAttributedString {
        self.colorArt = colorArt
        
        let formattedFollowersCount = formattedCount(blog.followerCountNum)
        let formattedFollowersLabel = formattedLabel(" Followers  ")
        let formattedTracksCount = formattedCount(blog.trackCountNum)
        let formattedTracksLabel = formattedLabel(" Tracks")
        
        let blogDetails = NSMutableAttributedString()
        blogDetails.append(formattedFollowersCount)
        blogDetails.append(formattedFollowersLabel)
        blogDetails.append(formattedTracksCount)
        blogDetails.append(formattedTracksLabel)
        
        return blogDetails
    }
    
    func formattedCount(_ count: NSNumber) -> NSAttributedString {
        let countString = LovedCountFormatter().string(for: count)!
        return NSAttributedString(string: countString, attributes: countAttributes())
    }
    
    func formattedLabel(_ text: String) -> NSAttributedString {
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
            return NSColor.black
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
            return NSColor.black
        }
    }
    
    func getFont() -> NSFont {
        return appFont(size: 13, weight: .medium)
    }
}
