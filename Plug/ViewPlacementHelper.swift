//
//  File.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

struct ViewPlacementHelper {
    static func AddFullSizeSubview(subview: NSView, toSuperView superview: NSView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(subview)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[view]|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
    }
    
    static func AddFullSizeConstaintsToSubview(subview: NSView, superview: NSView) {
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[view]|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
    }
    
    static func AddSubview(subview: NSView, toSuperView superview: NSView, withInsets insets: NSEdgeInsets) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(subview)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-\(insets.left)-[view]-\(insets.right)-|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(insets.top)-[view]-\(insets.bottom)-|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
    }
    
    static func AddTopAnchoredSubview(subview: NSView, toSuperView superview: NSView, withFixedHeight height: CGFloat) {
        let insets = NSEdgeInsetsMake(0,0,0,0)
        AddTopAnchoredSubview(subview, toSuperView: superview, withFixedHeight: height, andInsets: insets)
    }
    
    static func AddTopAnchoredSubview(subview: NSView, toSuperView superview: NSView, withFixedHeight height: CGFloat, andInsets insets: NSEdgeInsets) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(subview)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-\(insets.left)-[view]-\(insets.right)-|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(insets.top)-[view]", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view(\(height))]", options: nil, metrics: nil, views: ["view": subview])
        for constraint in constraints {
            if constraint is NSLayoutConstraint {
               (constraint as! NSLayoutConstraint).priority = 750
            }
        }
        superview.addConstraints(constraints)
    }
    
    static func AddBottomAnchoredSubview(subview: NSView, toSuperView superview: NSView, withFixedHeight height: CGFloat, andInsets insets: NSEdgeInsets) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(subview)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-\(insets.left)-[view]-\(insets.right)-|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view]-\(insets.bottom)-|", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view(\(height))]", options: nil, metrics: nil, views: ["view": subview])
        superview.addConstraints(constraints)
    }
}