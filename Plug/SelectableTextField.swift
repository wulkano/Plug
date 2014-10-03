//
//  SelectableTextField.swift
//  Plug
//
//  Created by Alex Marchant on 10/3/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SelectableTextField: NSTextField {
    @IBInspectable var selected: Bool = false {
        didSet {
            if selected {
                defaultTextColor = textColor
                textColor = selectedTextColor
            } else {
                if defaultTextColor != nil {
                    textColor = defaultTextColor
                }
            }
        }
    }
    @IBInspectable var selectedTextColor: NSColor = NSColor(red256: 255, green256: 95, blue256: 82)
    var defaultTextColor: NSColor?
}
