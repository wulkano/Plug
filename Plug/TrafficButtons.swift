//
//  TrafficButtons.swift
//  Plug
//
//  Created by Alex Marchant on 10/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

class TrafficButtons {
    var closeButton: INWindowButton!
    var minimizeButton: INWindowButton!
    var zoomButton: INWindowButton!
    
    let buttonSize = NSMakeSize(14, 16)
    
    init(style: TrafficButtonStyle, groupIdentifier: String) {
        
        closeButton = INWindowButton(size: buttonSize, groupIdentifier: groupIdentifier)
        setupImagesForButton(&closeButton, buttonName: "close", style: style)
        
        minimizeButton = INWindowButton(size: buttonSize, groupIdentifier: groupIdentifier)
        setupImagesForButton(&minimizeButton, buttonName: "minimize", style: style)
        
        zoomButton = INWindowButton(size: buttonSize, groupIdentifier: groupIdentifier)
        setupImagesForButton(&zoomButton, buttonName: "zoom", style: style)
    }
    
    func addButtonsToWindow(window: NSWindow, origin: NSPoint) {
        hideDefaultButtons(window)
        placeButtonsInWindow(window, origin: origin)
        setupButtonActionsForWindow(window)
    }
    
    private func setupImagesForButton(inout button: INWindowButton!, buttonName: String, style: TrafficButtonStyle) {
        button.activeImage = NSImage(named: "traffic-\(buttonName)-\(style.stringValue())")
        button.activeNotKeyWindowImage = NSImage(named: "traffic-disabled-\(style.stringValue())")
        button.inactiveImage = NSImage(named: "traffic-disabled-\(style.stringValue())")
        button.rolloverImage = NSImage(named: "traffic-\(buttonName)-hover-\(style.stringValue())")
        button.pressedImage = NSImage(named: "traffic-\(buttonName)-down-\(style.stringValue())")
    }
    
    private func hideDefaultButtons(window: NSWindow) {
        window.standardWindowButton(NSWindowButton.CloseButton)!.hidden = true
        window.standardWindowButton(NSWindowButton.MiniaturizeButton)!.hidden = true
        window.standardWindowButton(NSWindowButton.ZoomButton)!.hidden = true
    }
    
    private func placeButtonsInWindow(window: NSWindow, origin: NSPoint) {
        let contentView = window.contentView! as NSView
        
        var buttonOrigin = origin
        addButton(closeButton, toView: contentView, origin: buttonOrigin)
        
        buttonOrigin = NSMakePoint(buttonOrigin.x + 20, buttonOrigin.y)
        addButton(minimizeButton, toView: contentView, origin: buttonOrigin)
        
        buttonOrigin = NSMakePoint(buttonOrigin.x + 20, buttonOrigin.y)
        addButton(zoomButton, toView: contentView, origin: buttonOrigin)
    }
    
    private func addButton(button: INWindowButton, toView superview: NSView, origin: NSPoint) {
        button.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(button)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|-\(origin.x)-[button]", options: nil, metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(origin.y)-[button]", options: nil, metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("[button(\(buttonSize.width))]", options: nil, metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[button(\(buttonSize.height))]", options: nil, metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
    }
    
    private func setupButtonActionsForWindow(window: NSWindow) {
        closeButton.target = window
        closeButton.action = "close"
        
        minimizeButton.target = window
        minimizeButton.action = "miniaturize:"
        
        zoomButton.target = window
        zoomButton.action = "zoom:"
    }
}

enum TrafficButtonStyle {
    case Dark
    case Light
    
    func stringValue() -> String {
        switch self {
        case .Dark:
            return "dark"
        case .Light:
            return "light"
        }
    }
}

