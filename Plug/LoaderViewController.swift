//
//  LoaderViewController.swift
//  Plug
//
//  Created by Alex Marchant on 9/5/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoaderViewController: NSViewController {
    
    @IBOutlet var loaderView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear() {
        startAnimation()
    }
    
    func startAnimation() {
        Animations.RotateClockwise(loaderView)
    }
    
    func stopAnimation() {
        Animations.RemoveAllAnimations(loaderView)
    }
    
}
