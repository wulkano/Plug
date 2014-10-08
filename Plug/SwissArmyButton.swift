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
        return cell() as SwissArmyButtonCell
    }
    var mouseInside: Bool {
        get { return swissArmyButtonCell.mouseInside }
        set { swissArmyButtonCell.mouseInside = newValue }
    }
    var mouseDown: Bool {
        get { return swissArmyButtonCell.mouseDown }
        set { swissArmyButtonCell.mouseDown = newValue }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if tracksHover {
            ensureTrackingArea()
            if find(trackingAreas as [NSTrackingArea], trackingArea!) == nil {
                addTrackingArea(trackingArea!)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupCell()
    }
    
    func setupCell() {
        let newCell = SwissArmyButtonCell(textCell: "")
        setCell(newCell)
    }
    
    func ensureTrackingArea() {
        if trackingArea == nil {
            trackingArea = NSTrackingArea(rect: NSZeroRect, options: NSTrackingAreaOptions.InVisibleRect | NSTrackingAreaOptions.ActiveAlways | NSTrackingAreaOptions.MouseEnteredAndExited, owner: self, userInfo: nil)
        }
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