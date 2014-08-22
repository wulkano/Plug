//
//  AppDelegate.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: NSWindowController?
    var loginWindowController: NSWindowController?
    
//    TODO: Switch release channel compilation flag back to fast when they fix some bug
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        setupUserDefaults()
        
        if userSignedIn() {
            openMainWindow()
        } else {
            openLoginWindow()
        }
    }
    
    func openMainWindow() {
        if mainWindowController == nil {
            mainWindowController = NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as? NSWindowController
        }
        mainWindowController!.showWindow(self)
    }
    
    func openLoginWindow() {
        if loginWindowController == nil {
            loginWindowController = NSStoryboard(name: "Login", bundle: nil).instantiateInitialController() as? NSWindowController
        }
        loginWindowController!.showWindow(self)
    }
    
    func closeMainWindow() {
        mainWindowController!.window.close()
        mainWindowController = nil
    }
    
    func closeLoginWindow() {
        loginWindowController!.window.close()
        loginWindowController = nil
    }
    
    func finishedSigningIn() {
        closeLoginWindow()
        openMainWindow()
    }
    
    private func setupUserDefaults() {
        let userDefaultsValuesPath = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")!
        let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)
        NSUserDefaults.standardUserDefaults().registerDefaults(userDefaultsValuesDict)
    }
    
    private func userSignedIn() -> Bool {
        return false
    }
}