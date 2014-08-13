//
//  LargeLoadingView.swift
//  Plug
//
//  Created by Alex Marchant on 7/24/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import QuartzCore

class LargeLoadingView: NSView {
    let spinnerImage = NSImage(named: "Loader-Large")
    var spinnerView: NSImageView!

    override init(frame: NSRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    func initialSetup() {
        var spinnerFrame = NSZeroRect
        spinnerFrame.size = spinnerImage.size
        spinnerView = NSImageView(frame: spinnerFrame)
        spinnerView.wantsLayer = true
        spinnerView.image = spinnerImage
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinnerView)
        addConstraintsToSpinnerView()
    }
    
    func addConstraintsToSpinnerView() {
        addConstraint(NSLayoutConstraint(item: spinnerView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: spinnerView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: -23)) // -23 makes up for the 47px footer overlap
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("[view(\(spinnerImage.size.width))]", options: nil, metrics: nil, views: ["view": spinnerView])
        spinnerView.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view(\(spinnerImage.size.height))]", options: nil, metrics: nil, views: ["view": spinnerView])
        spinnerView.addConstraints(constraints)
    }
    
    func startAnimation() {
        // TODO: This shit don't work, rotates around wrong axis
        // Can't change anchorPoint, why???
//        let rotation = CABasicAnimation(keyPath: "transform.rotation")
//        rotation.fromValue = NSNumber(double: 0)
//        rotation.toValue = NSNumber(double: -2 * M_PI)
//        rotation.duration = 1.1 // Speed
//        rotation.repeatCount = 1 // Float.infinity // Repeat forever. Can be a finite number.
//        spinnerView.layer!.addAnimation(rotation, forKey: "spin")
    }
}
