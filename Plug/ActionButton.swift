//
//  ActionButton.swift
//  Plug
//
//  Created by Alex Marchant on 6/16/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class ActionButton: SwissArmyButton {
    var actionButtonCell: ActionButtonCell {
        return cell as! ActionButtonCell
    }
    var horizontalPadding: CGFloat {
        return actionButtonCell.horizontalPadding
    }
    var offStateTitle: String {
        set { actionButtonCell.offStateTitle = newValue }
        get { return actionButtonCell.offStateTitle }
    }
    var onStateTitle: String {
        set { actionButtonCell.onStateTitle = newValue }
        get { return actionButtonCell.onStateTitle }
    }
    
    override var intrinsicContentSize: NSSize {
        var newSize = super.intrinsicContentSize
        newSize.width += horizontalPadding
        return newSize
    }
}
