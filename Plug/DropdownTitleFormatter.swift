//
//  DropdownTitleFormatter.swift
//  Plug
//
//  Created by Alex Marchant on 6/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class DropdownTitleFormatter: Formatter {
    
    override func attributedString(for obj: Any, withDefaultAttributes attrs: [String : Any]?) -> NSAttributedString? {
        return attributedDropdownTitle("Popular", optionTitle: "Now")
    }
    
    override func string(for obj: Any?) -> String? {
        return attributedDropdownTitle("Popular", optionTitle: "Now").string
    }
    
    func attributedDropdownTitle(_ title: String?, optionTitle: String?) -> NSAttributedString {
        let formattedViewTitle = formatViewTitle(title ?? "")
        let formattedOptionTitle = formatOptionTitle(optionTitle ?? "")
        
        let dropdownTitle = NSMutableAttributedString()
        dropdownTitle.append(formattedViewTitle)
        dropdownTitle.append(formattedOptionTitle)
        
        return dropdownTitle
    }
    
    fileprivate func formatViewTitle(_ viewTitle: String) -> NSAttributedString {
        return NSAttributedString(string: viewTitle, attributes: viewTitleAttributes())
    }
    
    fileprivate func formatOptionTitle(_ optionTitle: String) -> NSAttributedString {
        return NSAttributedString(string: " (\(optionTitle))", attributes: optionTitleAttributes())
    }
    
    fileprivate func viewTitleAttributes() -> [String: AnyObject] {
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = NSColor(red256: 0, green256: 0, blue256: 0)
        attributes[NSFontAttributeName] = getFont()
        return attributes
    }
    
    fileprivate func optionTitleAttributes() -> [String: AnyObject] {
        var attributes = [String: AnyObject]()
        attributes[NSForegroundColorAttributeName] = NSColor(white: 0, alpha: 0.4)
        attributes[NSFontAttributeName] = getFont()
        return attributes
    }
    
    fileprivate func getFont() -> NSFont {
        return appFont(size: 14, weight: .medium)
    }
}
