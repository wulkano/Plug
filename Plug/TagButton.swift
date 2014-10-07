//
//  TagButton.swift
//  Plug
//
//  Created by Alex Marchant on 10/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TagButton: SwissArmyButton {
    var tagButtonCell: TagButtonCell {
        return cell() as TagButtonCell
    }
    var backgroundColor: Bool {
        get { return tagButtonCell.backgroundColo }
        set { tagButtonCell.backgroundColo = newValue }
    }
}
