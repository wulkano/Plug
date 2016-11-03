//
//  NavigationItem.swift
//  Plug
//
//  Created by Alex Marchant on 7/15/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class NavigationItem: NSObject {
    var title: String
    var rightButton: ActionButton?
    var titleView: NSView?
    
    init(title: String) {
        self.title = title
        super.init()
    }
    
    class func standardBackButtonWithTitle(_ title: String) -> SwissArmyButton {
        let button = SwissArmyButton(frame: NSZeroRect)
        let cell = BackButtonCell(textCell: "")
        button.cell = cell
        button.bezelStyle = .regularSquare
        button.isBordered = true
        button.font = appFont(size: 13, weight: .medium)
        button.title = title
        
        return button
    }
    
    class func standardRightButtonWithOnStateTitle(_ onStateTitle: String, offStateTitle: String, target: AnyObject, action: Selector) -> ActionButton {
        let button = ActionButton(frame: NSZeroRect)
        let cell = ActionButtonCell(textCell: "")
        
        button.cell = cell
        button.onStateTitle = onStateTitle
        button.offStateTitle = offStateTitle
        button.state = NSOffState
        button.bezelStyle = .regularSquare
        button.isBordered = true
        button.font = appFont(size: 13, weight: .medium)
        button.target = target
        button.action = action
        
        return button
    }
    
    class func standardTitleDropdownButtonForMenu(_ menu: NSMenu) -> TitleBarPopUpButton {
        let button = TitleBarPopUpButton(frame: NSZeroRect, pullsDown: true)
        let buttonCell = TitleBarPopUpButtonCell(textCell: "", pullsDown: true)
        
        buttonCell.altersStateOfSelectedItem = true
        buttonCell.usesItemFromMenu = true
        buttonCell.arrowPosition = .arrowAtBottom
        
        button.cell = buttonCell
        button.autoenablesItems = true
        button.preferredEdge = NSRectEdge.maxY
        button.setContentCompressionResistancePriority(490, for: .horizontal)
        button.lineBreakMode = .byTruncatingMiddle
        button.menu = menu
        
        return button
    }
}
