//
//  TrafficButtons.swift
//  Plug
//
//  Created by Alex Marchant on 10/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation
import INAppStoreWindow

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
    
    func addButtonsToWindow(_ window: NSWindow, origin: NSPoint) {
        hideDefaultButtons(window)
        placeButtonsInWindow(window, origin: origin)
        setupButtonActionsForWindow(window)
    }
    
    fileprivate func setupImagesForButton(_ button: inout INWindowButton!, buttonName: String, style: TrafficButtonStyle) {
        button.activeImage = NSImage(named: "traffic-\(buttonName)-\(style.stringValue())")
        button.activeNotKeyWindowImage = NSImage(named: "traffic-disabled-\(style.stringValue())")
        button.inactiveImage = NSImage(named: "traffic-disabled-\(style.stringValue())")
        button.rolloverImage = NSImage(named: "traffic-\(buttonName)-hover-\(style.stringValue())")
        button.pressedImage = NSImage(named: "traffic-\(buttonName)-down-\(style.stringValue())")
    }
    
    fileprivate func hideDefaultButtons(_ window: NSWindow) {
		window.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
		window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)!.isHidden = true
		window.standardWindowButton(NSWindow.ButtonType.zoomButton)!.isHidden = true
    }
    
    fileprivate func placeButtonsInWindow(_ window: NSWindow, origin: NSPoint) {
        let contentView = window.contentView!
        
        var buttonOrigin = origin
        addButton(closeButton, toView: contentView, origin: buttonOrigin)
        
        buttonOrigin = NSMakePoint(buttonOrigin.x + 20, buttonOrigin.y)
        addButton(minimizeButton, toView: contentView, origin: buttonOrigin)
        
        buttonOrigin = NSMakePoint(buttonOrigin.x + 20, buttonOrigin.y)
        addButton(zoomButton, toView: contentView, origin: buttonOrigin)
    }
    
    fileprivate func addButton(_ button: INWindowButton, toView superview: NSView, origin: NSPoint) {
        button.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(button)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-\(origin.x)-[button]", options: [], metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(origin.y)-[button]", options: [], metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "[button(\(buttonSize.width))]", options: [], metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[button(\(buttonSize.height))]", options: [], metrics: nil, views: ["button": button])
        superview.addConstraints(constraints)
    }
    
    fileprivate func setupButtonActionsForWindow(_ window: NSWindow) {
        closeButton.target = window
        closeButton.action = #selector(window.close)
        
        minimizeButton.target = window
        minimizeButton.action = #selector(window.miniaturize)
        
        zoomButton.target = window
        zoomButton.action = #selector(window.zoom)
    }
}

enum TrafficButtonStyle {
    case dark
    case light
    
    func stringValue() -> String {
        switch self {
        case .dark:
            return "dark"
        case .light:
            return "light"
        }
    }
}

