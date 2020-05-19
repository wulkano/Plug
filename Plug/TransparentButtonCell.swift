//
//  NavigationButtonCell.swift
//  Plug
//
//  Created by Alex Marchant on 9/10/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TransparentButtonCell: SwissArmyButtonCell {
    @IBInspectable var allowsSelectedState: Bool = false
    
    let selectedOpacity: CGFloat = 1
    let mouseDownOpacity: CGFloat = 1
    let mouseInsideOpacity: CGFloat = 0.7
    let inactiveOpacity: CGFloat = 0.3
    
    override func drawImage(_ image: NSImage, withFrame frame: NSRect, in controlView: NSView) {
        
        let alpha = getImageAlpha()
        if let drawImage = getDrawImage() {
            drawImage.draw(in: frame, from: NSZeroRect, operation: .sourceOver, fraction: alpha, respectFlipped: true, hints: nil)
        }
    }
    
    func getImageAlpha() -> CGFloat {
		if allowsSelectedState && state == .on {
            return selectedOpacity
        } else if mouseDown {
            return mouseDownOpacity
        } else if mouseInside {
            return mouseInsideOpacity
        } else {
            return inactiveOpacity
        }
    }
    
    func getDrawImage() -> NSImage? {
		if allowsSelectedState && state == .on {
            return alternateImage ?? image
        } else if mouseDown {
            return image
        } else if mouseInside {
            return image
        } else {
            return image
        }
    }
    
}
