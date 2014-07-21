//
//  FooterViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FooterViewController: NSViewController {
    @IBOutlet var volumeIcon: VolumeIconView
    @IBOutlet var volumeSlider: NSSlider
    var volume: Double = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        volumeSlider.bind("value", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
        volumeIcon.bind("volume", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
    }
}
