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
    
    class func standardBackButtonWithTitle(title: String) -> SwissArmyButton {
        let button = SwissArmyButton(frame: NSZeroRect)
        let cell = BackButtonCell(textCell: "")
        button.setCell(cell)
        button.bezelStyle = .RegularSquareBezelStyle
        button.bordered = true
        button.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        button.title = title
        return button
    }
    
    class func standardRightButtonWithOnStateTitle(onStateTitle: String, offStateTitle: String, target: AnyObject, action: Selector) -> ActionButton {
        let button = ActionButton(frame: NSZeroRect)
        let cell = ActionButtonCell(textCell: "")
        
        button.setCell(cell)
        button.onStateTitle = onStateTitle
        button.offStateTitle = offStateTitle
        button.state = NSOffState
        button.bezelStyle = .RegularSquareBezelStyle
        button.bordered = true
        button.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        button.target = target
        button.action = action
        
        return button
    }
    
    class func standardTitleDropdownButtonForMenu(menu: NSMenu) -> TitleBarPopUpButton {
        let button = TitleBarPopUpButton(frame: NSZeroRect, pullsDown: true)
        let buttonCell = TitleBarPopUpButtonCell(textCell: "", pullsDown: true)
        
        buttonCell.altersStateOfSelectedItem = true
        buttonCell.usesItemFromMenu = true
        buttonCell.arrowPosition = .ArrowAtBottom
        button.setCell(buttonCell)
        
        button.autoenablesItems = true
        button.preferredEdge = NSMaxYEdge
        button.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
        button.lineBreakMode = .ByTruncatingMiddle
        button.menu = menu
        
        return button
    }
}
