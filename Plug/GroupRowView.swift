//
//  GroupRowView.swift
//  Plug
//
//  Created by Alex Marchant on 7/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GroupRowView: NSTableRowView {
    let backgroundFill = NSColor(red256: 244, green256: 244, blue256: 245)
    let lineFill = NSColor(red256: 225, green256: 230, blue256: 233)

    override func draw(_ dirtyRect: NSRect) {
        drawBackground(dirtyRect)
        drawSeparators(dirtyRect)
    }

    func drawBackground(_ dirtyRect: NSRect) {
        backgroundFill.set()
		dirtyRect.fill()
    }

    func drawSeparators(_ dirtyRect: NSRect) {
        var bottomSeparatorRect = bounds
        bottomSeparatorRect.origin.y = bounds.size.height - 1
        bottomSeparatorRect.size.height = 1

        lineFill.set()
		bottomSeparatorRect.intersection(dirtyRect).fill()
    }
}
