//
//  SwissArmyButton.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SwissArmyButton: NSButton {
    @IBInspectable var vibrant: Bool = false
    @IBInspectable var tracksHover: Bool = false

    override var allowsVibrancy: Bool {
        return vibrant
    }
    override var state: Int {
        didSet { needsDisplay = true }
    }
    var trackingArea: NSTrackingArea?
    var swissArmyButtonCell: SwissArmyButtonCell {
        return cell() as! SwissArmyButtonCell
    }
    var mouseInside: Bool {
        get { return swissArmyButtonCell.mouseInside }
        set { swissArmyButtonCell.mouseInside = newValue }
    }
    var mouseDown: Bool {
        get { return swissArmyButtonCell.mouseDown }
        set { swissArmyButtonCell.mouseDown = newValue }
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        if tracksHover {
            let options: NSTrackingAreaOptions = (.InVisibleRect | .ActiveAlways | .MouseEnteredAndExited)
            let trackingArea = NSTrackingArea(rect: NSZeroRect, options: options, owner: self, userInfo: nil)
            addTrackingArea(trackingArea)
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {
        setupCell()
        
        bordered = false
    }
    
    func setupCell() {
        let newCell = SwissArmyButtonCell(textCell: "")
        setCell(newCell)
    }
    
    override func mouseEntered(theEvent: NSEvent) {
        mouseInside = true
        needsDisplay = true
    }
    
    override func mouseExited(theEvent: NSEvent) {
        mouseInside = false
        needsDisplay = true
    }
    
    override func mouseDown(theEvent: NSEvent) {
        mouseDown = true
        needsDisplay = true
        super.mouseDown(theEvent)
        mouseUp(theEvent)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        mouseDown = false
        needsDisplay = true
        super.mouseUp(theEvent)
    }
}