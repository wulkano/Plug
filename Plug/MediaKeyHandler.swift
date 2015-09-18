//
//  MediaKeyHandler.swift
//  Plug
//
//  Created by Alex Marchant on 9/11/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MediaKeyHandler: NSObject {
    class var sharedInstance: MediaKeyHandler {
        struct Singleton {
            static let instance = MediaKeyHandler()
        }
        return Singleton.instance
    }
    
    var keyTap: SPMediaKeyTap!
    
    override init() {
        super.init()
        
        initialSetup()
    }
    
    func initialSetup() {
        keyTap = SPMediaKeyTap(delegate: self)
        
        registerWhitelist()
        
        if SPMediaKeyTap.usesGlobalMediaKeyTap() {
            keyTap.startWatchingMediaKeys()
        } else {
            print("Media key monitoring disabled")
        }
    }
    
    override func mediaKeyTap(keyTap: SPMediaKeyTap!, receivedMediaKeyEvent event: NSEvent!) {
        
        assert((event.type == NSEventType.SystemDefined && event.subtype.rawValue == Int16(SPSystemDefinedEventMediaKeys)), "Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:")

        // here be dragons...
        
        let keyCode: Int = (event.data1 & 0xFFFF0000) >> 16
        let keyFlags: Int = (event.data1 & 0x0000FFFF)
        let keyIsPressed: Bool = ((keyFlags & 0xFF00) >> 8) == 0xA
        let keyRepeat: Int = (keyFlags & 0x1)
        
        if keyIsPressed {
            var debugString = keyRepeat == 1 ? ", repeated." : "."
            
            switch keyCode {
            case Int(NX_KEYTYPE_PLAY):
                debugString = "Play/pause pressed" + debugString
                AudioPlayer.sharedInstance.playPauseToggle()
            case Int(NX_KEYTYPE_FAST):
                debugString = "Ffwd pressed" + debugString
                AudioPlayer.sharedInstance.skipForward()
            case Int(NX_KEYTYPE_REWIND):
                debugString = "Rewind pressed" + debugString
                AudioPlayer.sharedInstance.skipBackward()
            default:
                debugString = "Key \(keyCode) pressed" + debugString
            }
            
            print(debugString)
        }
    }
    
    func registerWhitelist() {
        let dictionary: [String: AnyObject] = [
            kMediaKeyUsingBundleIdentifiersDefaultsKey: SPMediaKeyTap.defaultMediaKeyUserBundleIdentifiers(),
        ]
        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
    }
}
