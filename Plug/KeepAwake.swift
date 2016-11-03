//
//  KeepAwake.swift
//  Plug
//
//  Created by Jesse Claven on 1/07/2016.
//  Copyright © 2016 Plug. All rights reserved.
//
// Thanks to https://gist.github.com/mikeabdullah/3200382 and 
// https://developer.apple.com/library/mac/qa/qa1340/_index.html
//

import Foundation
import IOKit.pwr_mgt
import PreventSleep
import Swignals

class KeepAwake: NSObject {
    class var sharedInstance: KeepAwake {
        struct Singleton {
            static let instance = KeepAwake()
        }
        return Singleton.instance
    }
    
    let preventSleep = PreventSleep(
        sleepAssertionMsg: "Prevent idle sleep when playing audio.",
        sleepAssertionType: kIOPMAssertionTypeNoIdleSleep
    )!
    
    fileprivate override init() {
        super.init()
        
        self.initialSetup()
    }
    
    fileprivate func initialSetup() {
        AudioPlayer.sharedInstance.onTrackPlaying.addObserver(self, callback: { (observer, arg1) in
            if self.getUserPreference() {
                self.preventSleep.preventSleep()
            }
        })

        let whenToAllowSleep: [Swignal1Arg<Bool>] = [
            AudioPlayer.sharedInstance.onTrackPaused,
            AudioPlayer.sharedInstance.onSkipForward,
            AudioPlayer.sharedInstance.onSkipBackward
        ]
        
        for aSignal in whenToAllowSleep {
            aSignal.addObserver(self, callback: { (observer, arg1) in
                self.preventSleep.allowSleep()
            })
        }
        
        UserDefaults.standard.addObserver(self, forKeyPath: PreventIdleSleepWhenPlaying, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    deinit {
        self.preventSleep.allowSleep()
    }
    
    // MARK: NSKeyValueObserving
    
    fileprivate func getUserPreference() -> Bool {
        return UserDefaults.standard.value(forKey: PreventIdleSleepWhenPlaying) as! Bool
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        if keyPath == PreventIdleSleepWhenPlaying {
            /* As the signal observers have already been set up, all we need to
             * do here is to prevent sleep if a track is currently being played.
             */
            if self.getUserPreference() && AudioPlayer.sharedInstance.playing {
                self.preventSleep.preventSleep()
            } else if !self.getUserPreference() {
                self.preventSleep.allowSleep()
            }
        }
    }
}
