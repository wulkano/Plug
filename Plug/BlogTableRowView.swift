//
//  BlogTableRowView.swift
//  Plug
//
//  Created by Alex Marchant on 7/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogTableRowView: NSTableRowView {
    @IBInspectable var separatorSpacer: CGFloat = 0
//    @IBInspectable var separatorColor: CGFloat = 0
    
    override func drawSeparatorInRect(dirtyRect: NSRect) {
        super.drawSeparatorInRect(dirtyRect)
    }
}
