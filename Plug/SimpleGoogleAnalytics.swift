//
//  SimpleGoogleAnalytics.swift
//  Alex Marchant
//
//  Created by Alex Marchant on 10/10/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Cocoa

class SimpleGoogleAnalytics: NSObject {
    let trackingID: String
    let apiBase = "https://ssl.google-analytics.com/collect"
    let GAClientIDKey = "GAClientIDKey"
    let requestManager = AFHTTPRequestOperationManager(baseURL: nil)
    
    init(trackingID: String) {
        self.trackingID = trackingID
        super.init()

        setupRequestManager()
    }
    
    func setupRequestManager() {
        requestManager.responseSerializer = AFHTTPResponseSerializer()
        requestManager.requestSerializer.setValue(userAgent(), forHTTPHeaderField: "User-Agent")
    }
    
    func userAgent() -> String {
        let osInfo = NSDictionary(contentsOfFile: "/System/Library/CoreServices/SystemVersion.plist")!
        let currentLocale = NSLocale.autoupdatingCurrentLocale()
        let productName = osInfo["ProductName"] as String
        let productVersion = (osInfo["ProductVersion"] as String).stringByReplacingOccurrencesOfString(".", withString: "_")
        let language = currentLocale.objectForKey(NSLocaleLanguageCode) as String
        let country = currentLocale.objectForKey(NSLocaleCountryCode) as String
        return "GoogleAnalytics/2.0 (Macintosh; Intel \(productName) \(productVersion); \(language)-\(country))"
    }
    
    func trackPageview(viewName: String) {
        let hit = ScreenviewHit(viewName: viewName)
        sendHit(hit)
    }
    
    func trackEvent(#category: String, action: String, label: String?, value: String?) {
        let hit = EventHit(category: category, action: action, label: label, value: value)
        sendHit(hit)
    }
    
    private func sendHit(hit: Hit) {
        let hitParams = hit.params()
        let params = defaultParams().merge(hitParams)
        requestManager.POST(apiBase,
            parameters: params,
            success: nil,
            failure: { opperation, error in
                println(error)
        })
    }
    
    private func defaultParams() -> [String: String] {
        var params: [String: String] = [
            "v": version(),
            "tid": trackingID,
            "cid": clientID(),
            "an": appName(),
            "av": appVersion(),
            "aid": appID(),
            "sr": screenResolution(),
            "sd": screenColors(),
            "ul": userLanguage(),
        ]
        if let uid = userID() {
            params["uid"] = uid
        }
        return params
    }
    
    private func version() -> String {
        return "1"
    }
    
    private func clientID() -> String {
        if let UUID = NSUserDefaults.standardUserDefaults().stringForKey(GAClientIDKey) {
            return UUID
        } else {
            let newUUID = generateClientID()
            NSUserDefaults.standardUserDefaults().setObject(newUUID, forKey: GAClientIDKey)
            return newUUID
        }
    }
    
    private func generateClientID() -> String {
        var newUUID = CFUUIDCreate(nil)
        var string = CFUUIDCreateString(nil, newUUID)
        return string
    }
    
    private func appName() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleNameKey) as String
    }
    
    private func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey) as String
    }
    
    private func appID() -> String {
        return NSBundle.mainBundle().bundleIdentifier!
    }
    
    func userID() -> String? {
        // subclass and override this method if you'd like to provide a custom userID
        return nil
    }
    
    private func screenResolution() -> String {
        let size = NSScreen.mainScreen()!.deviceDescription[NSDeviceSize]!.sizeValue
        let width = Int(size.width)
        let height = Int(size.height)
        return "\(width)x\(height)"
    }
    
    private func screenColors() -> String {
        let bits = NSBitsPerPixelFromDepth(NSScreen.mainScreen()!.depth)
        return "\(bits)-bit"
    }
    
    private func userLanguage() -> String {
        let lang = NSLocale.preferredLanguages()[0] as String
        let identifer = lang == "en" ? "en_US" : lang
        let locale = NSLocale(localeIdentifier: identifer)
        return "\(locale.objectForKey(NSLocaleLanguageCode)!)-\(locale.objectForKey(NSLocaleCountryCode)!)"
    }
}

protocol Hit {
    func description() -> String
    func params() -> [String: String]
}

