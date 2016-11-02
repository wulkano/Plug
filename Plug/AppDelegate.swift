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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupUserDefaults()
        // Load Crashlytics after setting up user defaults because we initialize
        // the exception handling settings there
        Fabric.with([Crashlytics()])
        setupUserNotifications()
        setupNotifications()
        setupMediaKeys()
        setupHypeMachineAPI()
        setupKeepAwake()
        
        if Authentication.UserSignedIn() {
            openMainWindow()
        } else {
            openLoginWindow()
        }
    }
    
    func openMainWindow() {
        if mainWindowController == nil {
            mainWindowController = (NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as! NSWindowController)
            
            /* If there isn't an autosave name set for the main window, place the
             * frame at a default position, and then set the autosave name.
             */
            if mainWindowController!.windowFrameAutosaveName!.isEmpty {
                let width: CGFloat = 472
                let height: CGFloat = 778
                let x: CGFloat = 100
                let y: CGFloat = (NSScreen.main()!.frame.size.height - 778) / 2

                let defaultFrame = NSMakeRect(x, y, width, height)
                mainWindowController!.window!.setFrame(defaultFrame, display: false)
                
                mainWindowController!.window!.setFrameAutosaveName("MainWindow")
            }
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
            let preferencesStoryboard = NSStoryboard(name: "Preferences", bundle: Bundle.main)
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
        preferencesMenuItem.isHidden = false
        preferencesMenuSeparator.isHidden = false
    }
    
    func hidePreferencesFromMenu() {
        preferencesMenuItem.isHidden = true
        preferencesMenuSeparator.isHidden = true
    }
    
    func showSignOutInMenu() {
        signOutMenuItem.isHidden = false
        signOutMenuSeparator.isHidden = false
    }
    
    func hideSignOutFromMenu() {
        signOutMenuItem.isHidden = true
        signOutMenuSeparator.isHidden = true
    }
    
    func setupUserDefaults() {
        let userDefaultsValuesPath = Bundle.main.path(forResource: "UserDefaults", ofType: "plist")!
        let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)!
        UserDefaults.standard.register(defaults: userDefaultsValuesDict as! [String : AnyObject])
    }
    
    func setupUserNotifications() {
        UserNotificationHandler.sharedInstance
    }
    
    func setupNotifications() {
        Notifications.subscribe(observer: self, selector: #selector(AppDelegate.catchTokenErrors(_:)), name: Notifications.DisplayError, object: nil)
    }
    
    func setupMediaKeys() {
        MediaKeyHandler.sharedInstance
    }
    
    func setupHypeMachineAPI() {
        HypeMachineAPI.apiKey = ApiKey
        if let hmToken = Authentication.GetToken() {
            HypeMachineAPI.hmToken = hmToken
        }
        
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let userAgent = "Plug for OSX/\(version)"
        HypeMachineAPI.userAgent = userAgent
    }
    
    func setupKeepAwake() {
        KeepAwake.sharedInstance
    }
    
    // MARK: Notifications
    
    func catchTokenErrors(_ notification: Notification) {
        let error = (notification as NSNotification).userInfo!["error"] as! NSError

        if error.code == HypeMachineAPI.APIError.invalidHMToken {
            signOut(nil)
        }
    }
    
    // MARK: Actions
    
    @IBAction func aboutItemClicked(_ sender: AnyObject) {
        openAboutWindow()
    }
    
    @IBAction func signOut(_ sender: AnyObject?) {
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
    
    @IBAction func preferencesItemClicked(_ sender: AnyObject) {
        openPreferencesWindow()
    }
    
    @IBAction func refreshItemClicked(_ sender: AnyObject) {
        Notifications.post(name: Notifications.RefreshCurrentView, object: self, userInfo: nil)
    }
    
    @IBAction func reportABugItemClicked(_ sender: AnyObject) {
        NSWorkspace.shared().open(URL(string: "https://github.com/PlugForMac/Plug2Issues/issues")!)
    }
    
    // MARK: NSApplicationDelegate
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        if Authentication.UserSignedIn() {
            return false
        } else {
            return true
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            openMainWindow()
        }
        return true
    }
}
