//
//  AppDelegate.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics
import HypeMachineAPI

class AppDelegate: NSObject, NSApplicationDelegate {
    var mainWindowController: NSWindowController?
    var loginWindowController: NSWindowController?
    var preferencesWindowController: NSWindowController?
    var aboutWindowController: AboutWindowController?
    @IBOutlet weak var preferencesMenuItem: NSMenuItem!
    @IBOutlet weak var preferencesMenuSeparator: NSMenuItem!
    @IBOutlet var signOutMenuItem: NSMenuItem!
    @IBOutlet var signOutMenuSeparator: NSMenuItem!
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Fabric.with([Crashlytics()]) // Crash Reporting
        setupUserDefaults()
        setupUserNotifications()
        setupNotifications()
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
            mainWindowController = (NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as! NSWindowController)
            
                let width: CGFloat = 472
                let height: CGFloat = 778
                let x: CGFloat = 100
                let y: CGFloat = (NSScreen.mainScreen()!.frame.size.height - 778) / 2

                var defaultFrame = NSMakeRect(x, y, width, height)
                mainWindowController!.window!.setFrame(defaultFrame, display: false)
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
            loginWindowController = (NSStoryboard(name: "Login", bundle: nil).instantiateInitialController() as! NSWindowController)
        }
        loginWindowController!.showWindow(self)
        hideSignOutFromMenu()
        hidePreferencesFromMenu()
    }
    
    func closeLoginWindow() {
        loginWindowController!.window!.close()
        loginWindowController = nil
    }
    
    func openAboutWindow() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController!.showWindow(self)
    }
    
    func openPreferencesWindow() {
        if preferencesWindowController == nil {
            let preferencesStoryboard = NSStoryboard(name: "Preferences", bundle: NSBundle.mainBundle())
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
    
    func setupUserDefaults() {
        let userDefaultsValuesPath = NSBundle.mainBundle().pathForResource("UserDefaults", ofType: "plist")!
        let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)!
        NSUserDefaults.standardUserDefaults().registerDefaults(userDefaultsValuesDict as [NSObject : AnyObject])
    }
    
    func setupUserNotifications() {
        UserNotificationHandler.sharedInstance
    }
    
    func setupNotifications() {
        Notifications.subscribe(observer: self, selector: "catchTokenErrors:", name: Notifications.DisplayError, object: nil)
    }
    
    func setupMediaKeys() {
        MediaKeyHandler.sharedInstance
    }
    
    func setupHypeMachineAPI() {
        HypeMachineAPI.apiKey = ApiKey
        if let hmToken = Authentication.GetToken() {
            HypeMachineAPI.hmToken = hmToken
        }
        
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let userAgent = "Plug for OSX/\(version)"
        HypeMachineAPI.userAgent = userAgent
    }
    
    // MARK: Notifications
    
    func catchTokenErrors(notification: NSNotification) {
        let error = notification.userInfo!["error"] as! NSError

        if error.code == HypeMachineAPI.ErrorCodes.InvalidHMToken.rawValue {
            signOut(nil)
        }
    }
    
    // MARK: Actions
    
    @IBAction func aboutItemClicked(sender: AnyObject) {
        openAboutWindow()
    }
    
    @IBAction func signOut(sender: AnyObject?) {
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
    
    @IBAction func reportABugItemClicked(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "https://github.com/PlugForMac/Plug2Issues/issues")!)
    }
    
    // MARK: NSApplicationDelegate
    
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