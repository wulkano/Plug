//
//  PostedByInfoFormatter.swift
//  Plug
//
//  Created by Alex Marchant on 8/29/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PostInfoFormatter: NSFormatter {
    
    func attributedStringForPostInfo(blogName: String, description: String, datePosted: NSDate) -> NSAttributedString {
        var postInfoAttributedString = NSMutableAttributedString()
        var formattedBlogName = attributedBlogName(blogName)
        var formattedDescription = attributedDescription(description)
        var formattedDatePosted = attributedDatePosted(datePosted)
        postInfoAttributedString.appendAttributedString(formattedBlogName)
        postInfoAttributedString.appendAttributedString(formattedDescription)
        postInfoAttributedString.appendAttributedString(formattedDatePosted)
        return postInfoAttributedString
    }
    
    private func attributedBlogName(blogName: String) -> NSAttributedString {
        return NSAttributedString(string: blogName, attributes: boldAttributes())
    }
    
    private func attributedDescription(description: String) -> NSAttributedString {
        var string = "  “\(description)...”  "
        return NSAttributedString(string: string, attributes: normalAttributes())
    }
    
    private func attributedDatePosted(datePosted: NSDate) -> NSAttributedString {
        var string = formattedDatePosted(datePosted)
        return NSAttributedString(string: string, attributes: boldAttributes())
    }
    
    private func formattedDatePosted(datePosted: NSDate) -> String {
        var formatter = NSDateFormatter()
        formatter.locale = NSLocale.currentLocale()
        if dateFromCurrentYear(datePosted) {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM d yyyy"
        }
        return formatter.stringFromDate(datePosted) + " →"
    }
    
    private func dateFromCurrentYear(date: NSDate) -> Bool {
        var dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear, fromDate: date)
        var todayComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitYear, fromDate: NSDate())
        return dateComponents.year == todayComponents.year
    }
    
    private func normalAttributes() -> [NSObject: AnyObject] {
        var attributes = [NSObject: AnyObject]()
        var color = NSColor.whiteColor().colorWithAlphaComponent(0.5)
        var font = NSFont(name: "HelveticaNeue", size: 13)
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = font
        return attributes
    }
    
    private func boldAttributes() -> [NSObject: AnyObject] {
        var attributes = [NSObject: AnyObject]()
        var color = NSColor.whiteColor()
        var font = NSFont(name: "HelveticaNeue-Medium", size: 13)
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = font
        return attributes
    }
}
