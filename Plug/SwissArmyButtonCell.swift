//
//  SwissArmyButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SwissArmyButtonCell: NSButtonCell {
    var mouseInside: Bool = false
    var mouseDown: Bool = false

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        highlightsBy = NSCellStyleMask()
    }
    
    override init(textCell aString: String) {
        super.init(textCell: aString)
        highlightsBy = NSCellStyleMask()
    }
}
