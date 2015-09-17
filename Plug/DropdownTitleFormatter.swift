//
//  DropdownTitleFormatter.swift
//  Plug
//
//  Created by Alex Marchant on 6/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class DropdownTitleFormatter: NSFormatter {
    
    override func attributedStringForObjectValue(obj: AnyObject, withDefaultAttributes attrs: [String : AnyObject]?) -> NSAttributedString? {
        return attributedDropdownTitle("Popular", optionTitle: "Now")
    }
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        return attributedDropdownTitle("Popular", optionTitle: "Now").string
    }
    
    func attributedDropdownTitle(title: String?, optionTitle: String?) -> NSAttributedString {
        let formattedViewTitle = formatViewTitle(title ?? "")
        let formattedOptionTitle = formatOptionTitle(optionTitle ?? "")
        
        let dropdownTitle = NSMutableAttributedString()
        dropdownTitle.appendAttributedString(formattedViewTitle)
        dropdownTitle.appendAttributedString(formattedOptionTitle)
        
        return dropdownTitle
    }
    
    private func formatViewTitle(viewTitle: String) -> NSAttributedString {
        return NSAttributedString(string: viewTitle, attributes: viewTitleAttributes())
    }
    
    private func formatOptionTitle(optionTitle: String) -> NSAttributedString {
        return NSAttributedString(string: " (\(optionTitle))", attributes: optionTitleAttributes())
    }
    
    private func viewTitleAttributes() -> [NSObject: AnyObject] {
        var attributes = [NSObject: AnyObject]()
        attributes[NSForegroundColorAttributeName] = NSColor(red256: 0, green256: 0, blue256: 0)
        attributes[NSFontAttributeName] = getFont()
        return attributes
    }
    
    private func optionTitleAttributes() -> [NSObject: AnyObject] {
        var attributes = [NSObject: AnyObject]()
        attributes[NSForegroundColorAttributeName] = NSColor(white: 0, alpha: 0.4)
        attributes[NSFontAttributeName] = getFont()
        return attributes
    }
    
    private func getFont() -> NSFont {
        return NSFont(name: "HelveticaNeue-Medium", size: 14)!
    }
}
