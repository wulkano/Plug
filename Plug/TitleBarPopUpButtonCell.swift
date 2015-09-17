//
//  TitleBarPopUpButton.swift
//  Plug
//
//  Created by Alex Marchant on 6/10/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class TitleBarPopUpButtonCell: NSPopUpButtonCell {
    var originalMenu: NSMenu?
    
    override var menu: NSMenu? {
        didSet {
            originalMenu = menu!.copy() as? NSMenu
        }
    }
    
    var trimPaddingBetweenArrowAndTitle: CGFloat = 5
    
    var formattedTitle: NSAttributedString {
        return DropdownTitleFormatter().attributedDropdownTitle(menu!.title, optionTitle: title)
    }
    
    var extraWidthForFormattedTitle: CGFloat {
        return formattedTitle.size().width - attributedTitle.size.width
    }
    
    var extraHeightForFormattedTitle: CGFloat {
        return formattedTitle.size().height - attributedTitle.size.height
    }
    
    override func drawTitle(title: NSAttributedString, withFrame frame: NSRect, inView controlView: NSView) -> NSRect {
        var newFrame = frame
        newFrame.size.width += trimPaddingBetweenArrowAndTitle
        newFrame.size.height += 4
        newFrame.origin.y -= 1
        return super.drawTitle(formattedTitle, withFrame: newFrame, inView: controlView)
    }
    
    override func drawBezelWithFrame(frame: NSRect, inView controlView: NSView) {
        drawArrow(frame, inView: controlView)
    }
    
    private func drawArrow(frame: NSRect, inView controlView: NSView) {
        let arrowColor = NSColor(white: 0, alpha: 0.4)
        
        let path = NSBezierPath()
        let bounds = controlView.bounds
        
        let leftPoint = NSMakePoint(bounds.size.width - 14, (bounds.size.height / 2) - 1)
        let bottomPoint = NSMakePoint(bounds.size.width - 10, (bounds.size.height / 2) + 3.5);
        let rightPoint = NSMakePoint(bounds.size.width - 6, (bounds.size.height / 2) - 1);
        
        path.moveToPoint(leftPoint)
        path.lineToPoint(bottomPoint)
        path.lineToPoint(rightPoint)
        
        arrowColor.set()
        path.lineWidth = 2
        path.stroke()
    }
    
    
    override func selectItem(item: NSMenuItem?) {
        super.selectItem(item)
        sortMenuForSelectedItem(item)
    }
    
    private func sortMenuForSelectedItem(item: NSMenuItem?) {
        let originalMenuItems = originalMenu!.itemArray
        let sortedItemArray = originalMenuItems.map { self.menu!.itemWithTitle($0.title)! }
        
        for sortItem in Array(sortedItemArray.reverse()) {
            if sortItem === item! { continue }
            
            menu!.removeItem(sortItem)
            menu!.insertItem(sortItem, atIndex: 0)
        }
        
        menu!.removeItem(item!)
        menu!.insertItem(item!, atIndex: 0)
    }
}