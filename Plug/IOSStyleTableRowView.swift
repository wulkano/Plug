//
//  IOSStyleTableRowView.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class IOSStyleTableRowView: NSTableRowView {
    override var isNextRowSelected: Bool {
        didSet { needsDisplay = true }
    }

    @IBInspectable var separatorSpacing: CGFloat = 0
    @IBInspectable var customSeparatorColor: NSColor = NSColor(red256: 225, green256: 230, blue256: 233)
    @IBInspectable var selectionColor: NSColor = NSColor(red256: 246, green256: 247, blue256: 249)

    var separatorWidth: CGFloat = 1
    var nextRowIsGroupRow: Bool = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        if shouldDrawSeparator() {
            let separatorRect = makeSeparatorRect(dirtyRect)
            customSeparatorColor.set()
			separatorRect.fill()
        }
    }

    // MARK: Separator
    // Had to disable default separator behavior, otherwise empty
    // row views drew the incorrect default separator
//    override func drawSeparatorInRect(dirtyRect: NSRect) {
//        if shouldDrawSeparator() {
//            let separatorRect = makeSeparatorRect(dirtyRect)
//            customSeparatorColor.set()
//            NSRectFill(separatorRect)
//        }
//    }

    func shouldDrawSeparator() -> Bool {
        if nextRowIsGroupRow { return true }
        if isSelected { return false }
        if isNextRowSelected { return false }
        return true
    }

    func makeSeparatorRect(_ dirtyRect: NSRect) -> NSRect {
        var separatorRect = bounds
        separatorRect.size.height = separatorWidth
        if !nextRowIsGroupRow {
            separatorRect.size.width = bounds.size.width - separatorSpacing
            separatorRect.origin.x = separatorSpacing
        }
        separatorRect.origin.y = bounds.size.height - separatorWidth
        return separatorRect.intersection(dirtyRect)
    }

    // MARK: Selection

    override func drawSelection(in dirtyRect: NSRect) {
        let selectionRect = bounds
        selectionColor.set()
		selectionRect.fill()
    }
}
