//
//  AppDelegate.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI
import Fabric
import Crashlytics

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: NSWindowController?
    var loginWindowController: NSWindowController?
    var preferencesWindowController: NSWindowController?
    @IBOutlet weak var preferencesMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesMenuSeparator: NSMenuItem!
    @IBOutlet var signOutMenuItem: NSMenuItem!
    @IBOutlet var signOutMenuSeparator: NSMenuItem!
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Fabric.with([Crashlytics()]) // Crash Reporting
        setupUserDefaults()
        setupUserNotifications()
        setupMediaKeys()
        setupHypeMachineAPI()
        
        if Authentication.UserSignedIn() {
            openMainWindow()
        } else {
            openLoginWindow()
        }
    }
    
    func openMainWindow() {
        if mainWindowController == nil {
            mainWindowController = (NSStoryboard(name: "Main", bundle: nil)!.instantiateInitialController() as! NSWindowController)
        }
        mainWindowController!.showWindow(self)
        showSignOutInMenu()
        showPreferencesInMenu()
    }
    
    func closeMainWindow() {
        mainWindowController!.window!.close()
        mainWindowController = nil
    }
    
    func openLoginWindow() {
        Analytics.trackView("LoginWindow")
        if loginWindowController == nil {
            loginWindowController = (NSStoryboard(name: "Login", bundle: nil)!.instantiateInitialController() as! NSWindowController)
        }
        loginWindowController!.showWindow(self)
        hideSignOutFromMenu()
        hidePreferencesFromMenu()
    }
    
    func closeLoginWindow() {
        loginWindowController!.window!.close()
        loginWindowController = nil
    }
    
    func openPreferencesWindow() {
        if preferencesWindowController == nil {
            let preferencesStoryboard = NSStoryboard(name: "Preferences", bundle: NSBundle.mainBundle())!
            preferencesWindowController = (preferencesStoryboard.instantiateInitialController() as! NSWindowController)
        }
        preferencesWindowController!.showWindow(self)
    }
    
    func closePreferencesWindow() {
        preferencesWindowController!.window!.close()
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
    
    @IBAction func signOut(sender: AnyObject) {
        Analytics.trackButtonClick("Sign Out")
        closeMainWindow()
        if preferencesWindowController != nil {
            closePreferencesWindow()
        }
        AudioPlayer.sharedInstance.reset()
        Authentication.DeleteUsernameAndToken()
        HypeMachineAPI.hmToken = nil
        openLoginWindow()
    }
    
    @IBAction func preferencesItemClicked(sender: AnyObject) {
        openPreferencesWindow()
    }
    
    @IBAction func refreshItemClicked(sender: AnyObject) {
        Notifications.post(name: Notifications.RefreshCurrentView, object: self, userInfo: nil)
    }
    
    private func setupUserDefaults() {
        let userDefaultsValuesPath = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")!
        let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)!
        NSUserDefaults.standardUserDefaults().registerDefaults(userDefaultsValuesDict as! [NSObject : AnyObject])
    }
    
    private func setupUserNotifications() {
        UserNotificationHandler.sharedInstance
    }
    
    private func setupMediaKeys() {
        MediaKeyHandler.sharedInstance
    }
    
    private func setupHypeMachineAPI() {
        HypeMachineAPI.apiKey = ApiKey
        if let hmToken = Authentication.GetToken() {
            HypeMachineAPI.hmToken = hmToken
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        if Authentication.UserSignedIn() {
            return false
        } else {
            return true
        }
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            openMainWindow()
        }
        return true
    }
}