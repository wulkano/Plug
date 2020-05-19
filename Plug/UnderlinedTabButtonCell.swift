//
//  UnderlinedTabViewItem.swift
//  Plug
//
//  Created by Alex Marchant on 8/25/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class UnderlinedTabButtonCell: NSButtonCell {
    var highlightColor: NSColor = NSColor(red256: 69, green256: 159, blue256: 255)
    var hightlightWidth: CGFloat = 4
    var fixedTextFrame: NSRect = NSMakeRect(5, 40, 50, 15)
    let maxImageHeight: CGFloat = 36
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
		highlightsBy = NSCell.StyleMask.contentsCellMask
    }
    
    override func drawBezel(withFrame frame: NSRect, in controlView: NSView) {
        if state == .on {
            let highlightRect = NSMakeRect(0, frame.size.height - hightlightWidth, frame.size.width, hightlightWidth)
            highlightColor.set()
			highlightRect.fill()
        }
    }
    
    override func drawTitle(_ title: NSAttributedString, withFrame frame: NSRect, in controlView: NSView) -> NSRect {
        
        // Consistent vertical placement
        return super.drawTitle(title, withFrame: fixedTextFrame, in: controlView)
    }
    
    override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
        
        // Center image vertically
        var newFrame = frame
        if maxImageHeight > image.size.height {
            let spacer = (maxImageHeight - image.size.height) / 2
            newFrame.origin.y += spacer
            newFrame.size.height += spacer
        }
        image.draw(in: newFrame)
    }
}
