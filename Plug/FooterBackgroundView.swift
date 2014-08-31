//
//  FooterBackgroundView.swift
//  Plug
//
//  Created by Alex Marchant on 8/30/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FooterBackgroundView: DraggableVisualEffectsView {
    override func viewDidMoveToWindow() {
        addTrackingRect(bounds, owner: self, userData: nil, assumeInside: false)
    }
    
    override func mouseEntered(theEvent: NSEvent!) {
        
    }
    
    override func mouseExited(theEvent: NSEvent!) {

    }
}
