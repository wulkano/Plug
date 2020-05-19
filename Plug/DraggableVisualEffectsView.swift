//
//  DraggableVisualEffectsView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/15/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class DraggableVisualEffectsView: NSVisualEffectView {
    override var mouseDownCanMoveWindow: Bool {
        true
    }
}
