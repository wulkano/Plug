//
//  VolumeIconView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class VolumeIconView: NSView {
    @IBInspectable var offImage: NSImage?
    @IBInspectable var oneImage: NSImage?
    @IBInspectable var twoImage: NSImage?
    @IBInspectable var threeImage: NSImage?
    var volumeState: VolumeState = VolumeState.Three {
    didSet {
        needsDisplay = true
    }
    }
    var volume: Double = 1 {
    didSet {
        println(volume)
        setStateForVolume(volume)
    }
    }
    var opacity: Double = 0.3

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        
        let drawImage = getDrawImage()
        var drawPoint = NSZeroPoint
        if drawImage {
            drawPoint.y = (bounds.size.height - drawImage!.size.height) / 2
        }
        drawImage?.drawAtPoint(drawPoint, fromRect: dirtyRect, operation: NSCompositingOperation.CompositeDestinationOver, fraction: opacity)
    }
    
    func setStateForVolume(volume: Double) {
        var newVolumeState: VolumeState
        
        if volume <= 0 {
            newVolumeState = VolumeState.Off
        } else if fraction <= (1 / 3) {
            newVolumeState = VolumeState.One
        } else if fraction <= (2 / 3) {
            newVolumeState = VolumeState.Two
        } else {
            newVolumeState = VolumeState.Three
        }
        
        // Avoid redraws if no change
        if volumeState != newVolumeState {
            volumeState = newVolumeState
        }
    }
    
    func getDrawImage() -> NSImage? {
        switch volumeState {
        case .Off:
            return offImage
        case .One:
            return oneImage
        case .Two:
            return twoImage
        case .Three:
            return threeImage
        }
    }
    
    enum VolumeState {
        case Off
        case One
        case Two
        case Three
    }
}
