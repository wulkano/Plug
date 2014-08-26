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
    var preferencesWindowController: NSWindowController?
    @IBOutlet weak var preferencesMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesMenuSeparator: NSMenuItem!
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
        showPreferencesInMenu()
    }
    
    func closeMainWindow() {
        mainWindowController!.window.close()
        mainWindowController = nil
    }
    
    func openLoginWindow() {
        if loginWindowController == nil {
            loginWindowController = NSStoryboard(name: "Login", bundle: nil).instantiateInitialController() as? NSWindowController
        }
        loginWindowController!.showWindow(self)
        hideSignOutFromMenu()
        hidePreferencesFromMenu()
    }
    
    func closeLoginWindow() {
        loginWindowController!.window.close()
        loginWindowController = nil
    }
    
    func openPreferencesWindow() {
        if preferencesWindowController == nil {
            preferencesWindowController = NSStoryboard(name: "Preferences", bundle: nil).instantiateInitialController() as? NSWindowController
        }
        preferencesWindowController!.showWindow(self)
    }
    
    func closePreferencesWindow() {
        preferencesWindowController!.window.close()
        preferencesWindowController = nil
    }
    
    func finishedSigningIn() {
        closeLoginWindow()
        openMainWindow()
    }
    
    func showPreferencesInMenu() {
        preferencesMenuItem.hidden = false
        preferencesMenuSeparator.hidden = false
    }
    
    func hidePreferencesFromMenu() {
        preferencesMenuItem.hidden = true
        preferencesMenuSeparator.hidden = true
    }
    
    func showSignOutInMenu() {
        signOutMenuItem.hidden = false
        signOutMenuSeparator.hidden = false
    }
    
    func hideSignOutFromMenu() {
        signOutMenuItem.hidden = true
        signOutMenuSeparator.hidden = true
    }
    
    @IBAction func signOut(sender: AnyObject!) {
        closeMainWindow()
        closePreferencesWindow()
        AudioPlayer.sharedInstance.reset()
        Authentication.DeleteUsernameAndToken()
        openLoginWindow()
    }
    
    @IBAction func preferencesItemClicked(sender: AnyObject!) {
        openPreferencesWindow()
    }
    
    private func setupUserDefaults() {
        let userDefaultsValuesPath = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")!
        let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)
        NSUserDefaults.standardUserDefaults().registerDefaults(userDefaultsValuesDict)
    }
}