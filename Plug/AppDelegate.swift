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
    @IBOutlet var signOutMenuItem: NSMenuItem!
    @IBOutlet var signOutMenuSeparator: NSMenuItem!
    
//    TODO: Switch release channel compilation flag back to fast when they fix some bug
    
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        setupUserDefaults()
        
        if Authentication.UserSignedIn() {
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
        showSignOutInMenu()
    }
    
    func openLoginWindow() {
        if loginWindowController == nil {
            loginWindowController = NSStoryboard(name: "Login", bundle: nil).instantiateInitialController() as? NSWindowController
        }
        loginWindowController!.showWindow(self)
        hideSignOutFromMenu()
    }
    
    func closeMainWindow() {
        mainWindowController!.window.close()
        mainWindowController = nil
        hideSignOutFromMenu()
    }
    
    func closeLoginWindow() {
        loginWindowController!.window.close()
        loginWindowController = nil
    }
    
    func finishedSigningIn() {
        closeLoginWindow()
        openMainWindow()
    }
    
    func hideSignOutFromMenu() {
        signOutMenuItem.hidden = true
        signOutMenuSeparator.hidden = true
    }
    
    func showSignOutInMenu() {
        signOutMenuItem.hidden = false
        signOutMenuSeparator.hidden = false
    }
    
    @IBAction func signOut(sender: AnyObject!) {
        closeMainWindow()
        AudioPlayer.sharedInstance.reset()
        Authentication.DeleteUsernameAndToken()
        openLoginWindow()
    }
    
    private func setupUserDefaults() {
        let userDefaultsValuesPath = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")!
        let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)
        NSUserDefaults.standardUserDefaults().registerDefaults(userDefaultsValuesDict)
    }
}