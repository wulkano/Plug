//
//  FooterViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FooterViewController: NSViewController {
    @IBOutlet var volumeIcon: VolumeIconView!
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var shuffleButton: TransparentButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        volumeSlider.bind("value", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
        volumeIcon.bind("volume", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.volume", options: nil)
        shuffleButton.selected = NSUserDefaults.standardUserDefaults().valueForKey("shuffle") as Bool
//            TODO: fix this binding
//            shuffleButton.bind("selected", toObject: NSUserDefaultsController.sharedUserDefaultsController(), withKeyPath: "values.shuffle", options: nil)
    }
    
    @IBAction func skipForwardButtonClicked(sender: TransparentButton) {
        AudioPlayer.sharedInstance.skipForward()
    }
    
    @IBAction func skipBackwardButtonClicked(sender: TransparentButton) {
        AudioPlayer.sharedInstance.skipBackward()
    }

    @IBAction func shuffleButtonClicked(sender: TransparentButton) {
        let shuffle = NSUserDefaults.standardUserDefaults().valueForKey("shuffle") as Bool
        let newShuffle = !shuffle
        NSUserDefaults.standardUserDefaults().setValue(newShuffle, forKey: "shuffle")
        shuffleButton.selected = newShuffle
    }
}