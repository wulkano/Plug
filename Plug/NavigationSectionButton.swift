//
//  NavigationSectionButton.swift
//  Plug
//
//  Created by Alex Marchant on 7/5/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class NavigationSectionButton: SwissArmyButton {
    let navigationSection: NavigationSection
    
    init(navigationSection: NavigationSection) {
        self.navigationSection = navigationSection
        super.init(frame: NSZeroRect)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let cell = TransparentButtonCell(textCell: "Go")
        cell.allowsSelectedState = true
        setCell(cell)
        
        tracksHover = true
        image = NSImage(named: "Nav-\(navigationSection.title)-Off")
        alternateImage = NSImage(named: "Nav-\(navigationSection.title)-On")
        setButtonType(NSButtonType.MomentaryPushInButton)
        bezelStyle = NSBezelStyle.RegularSquareBezelStyle
        bordered = false
    }
}
