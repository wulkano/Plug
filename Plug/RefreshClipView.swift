//
//  RefreshClipVIew.swift
//  Plug
//
//  Created by Alex Marchant on 7/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class RefreshClipView: NSClipView {
    var refreshScrollView: RefreshScrollView {
        superview! as! RefreshScrollView
    }
    var refreshHeaderController: RefreshHeaderViewController {
        refreshScrollView.refreshHeaderController
    }

    override var documentRect: NSRect {
        var newRect = super.documentRect

        // If refreshing expand the rect to fit the refresh header
        // in the frame (without scroll elaticity)
        if refreshHeaderController.state == .updating {
            newRect.size.height += refreshHeaderController.viewHeight
            newRect.origin.y -= refreshHeaderController.viewHeight
        }

        return newRect
    }

//    override func constrainBoundsRect(proposedBounds: NSRect) -> NSRect {
//        var constrainedBounds = super.constrainBoundsRect(proposedBounds)
//        println("proposed    \(proposedBounds)")
////        if constrainedBounds.origin.y < 0 {
//        constrainedBounds.origin.y += refreshScrollView.refreshHeaderHeight
////        }
//        println("constrained \(constrainedBounds)")
//        return constrainedBounds
//    }
}
