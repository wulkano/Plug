//
//  LoginImageView.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoginButtonImageView: NSImageView {
    override var allowsVibrancy: Bool {
        return true
    }
    
    var alpha: CGFloat = 1

    override func drawRect(dirtyRect: NSRect) {
        image.drawInRect(dirtyRect, fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeSourceOver, fraction: alpha)
    }
}
