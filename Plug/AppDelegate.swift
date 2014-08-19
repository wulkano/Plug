//
//  AppDelegate.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
//    TODO: Switch release channel compilation flag back to fast when they fix some bug
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        setupUserDefaults()
    }

    func applicationWillTerminate(aNotification: NSNotification?) {
    }
    
    func setupUserDefaults() {
        let userDefaultsValuesPath = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")!
        let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)
        NSUserDefaults.standardUserDefaults().registerDefaults(userDefaultsValuesDict)
    }
}