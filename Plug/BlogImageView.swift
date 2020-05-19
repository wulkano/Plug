//
//  BlogImageView.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogImageView: NSImageView {
    var sideLength: CGFloat {
        image!.size.width
    }
    var halfSideLength: CGFloat {
        sideLength / 2
    }

    override func draw(_ dirtyRect: NSRect) {
        if image != nil {
            NSGraphicsContext.saveGraphicsState()

            let imageRect = calulateImageRect()
            let clippingRect = calculateClippingRect()
            let path = NSBezierPath(roundedRect: clippingRect, xRadius: halfSideLength, yRadius: halfSideLength)
            path.addClip()

            image!.draw(in: bounds, from: imageRect, operation: .sourceOver, fraction: 1)

            NSGraphicsContext.restoreGraphicsState()
        }
    }

    func calulateImageRect() -> NSRect {
        var rect = NSRect.zero
        let croppedHeight = image!.size.height / 1.333_33

        rect.origin.x = 0
        rect.origin.y = image!.size.height - croppedHeight
        rect.size.width = image!.size.width
        rect.size.height = croppedHeight

        return rect
    }

    func calculateClippingRect() -> NSRect {
        var rect = NSRect.zero
        let veritcalOffset = -(frame.size.width - frame.size.height) / 2

        rect.origin.x = 0
        rect.origin.y = veritcalOffset
        rect.size.width = sideLength
        rect.size.height = sideLength

        return rect
    }
}
