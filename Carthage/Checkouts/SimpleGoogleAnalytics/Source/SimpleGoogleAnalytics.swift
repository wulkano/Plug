//
//  SimpleGoogleAnalytics.swift
//  Alex Marchant
//
//  Created by Alex Marchant on 10/10/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation
import Alamofire

public class Manager: NSObject {
    let trackingID: String
    let appBundle: NSBundle
    let userID: String?
    let apiBase = "https://ssl.google-analytics.com/collect"
    let GAClientIDKey = "GAClientIDKey"
    
    var requestManager: Alamofire.Manager!
    
    public init(trackingID: String, appBundle: NSBundle, userID: String?) {
        self.trackingID = trackingID
        self.appBundle = appBundle
        self.userID = userID
        
        super.init()

        setupRequestManager()
    }
    
    func setupRequestManager() {
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        defaultHeaders["User-Agent"] = userAgent()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        
        self.requestManager = Alamofire.Manager(configuration: configuration)
    }
    
    func userAgent() -> String {
        let osInfo = NSDictionary(contentsOfFile: "/System/Library/CoreServices/SystemVersion.plist")!
        let currentLocale = NSLocale.autoupdatingCurrentLocale()
        let productName = osInfo["ProductName"] as! String
        let productVersion = (osInfo["ProductVersion"] as! String).stringByReplacingOccurrencesOfString(".", withString: "_")
        let language = currentLocale.objectForKey(NSLocaleLanguageCode) as! String
        let country = currentLocale.objectForKey(NSLocaleCountryCode) as! String
        return "GoogleAnalytics/2.0 (Macintosh; Intel \(productName) \(productVersion); \(language)-\(country))"
    }
    
    public func trackPageview(viewName: String) {
        let hit = ScreenviewHit(viewName: viewName)
        sendHit(hit)
    }
    
    public func trackEvent(category category: String, action: String, label: String?, value: String?) {
        let hit = EventHit(category: category, action: action, label: label, value: value)
        sendHit(hit)
    }
    
    public func trackException(description description: String, fatal: Bool?) {
        let hit = ExceptionHit(description: description, fatal: fatal)
        sendHit(hit)
    }
    
    func sendHit(hit: Hit) {
        let hitParams = hit.params
        let params = defaultParams().merge(hitParams)
        requestManager.request(.POST, apiBase, parameters: params)
            .response { (_, _, _, error) in
                if error != nil {
                    print(error)
                }
            }
    }
    
    func defaultParams() -> [String: String] {
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
        if let uid = userID {
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
        let newUUID = CFUUIDCreate(nil)
        let string = CFUUIDCreateString(nil, newUUID) as String
        return string
    }
    
    private func appName() -> String {
        return appBundle.objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
    }
    
    private func appVersion() -> String {
        return appBundle.objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
    private func appID() -> String {
        return appBundle.bundleIdentifier!
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
        let locale = NSLocale.currentLocale()
        return "\(locale.objectForKey(NSLocaleLanguageCode)!)-\(locale.objectForKey(NSLocaleCountryCode)!)"
    }
}

// MARK: - Hit Protocol

protocol Hit {
     var description: String { get }
     var params: [String: String] { get }
}

public struct ScreenviewHit: Hit {
    let viewName: String
    var contentDescription: String {
        return viewName
    }
    
    init(viewName: String) {
        self.viewName = viewName
    }
    
    var description: String {
        return "<ScreenviewHit viewName: \(viewName)>"
    }
    
    var params: [String: String] {
        return [
            "t": "screenview",
            "cd": contentDescription,
        ]
    }
}

public struct EventHit: Hit {
    let category: String
    let action: String
    let label: String?
    let value: String?
    
    init(category: String, action: String, label: String?, value: String?) {
        self.category = category
        self.action = action
        self.label = label
        self.value = value
    }
    
    var description: String {
        return "<EventHit category: \(category), action: \(action), label: \(label), value: \(value)>"
    }
    
    var params: [String: String] {
        var params = [String: String]()
        params["t"] = "event"
        params["ec"] = category
        params["ea"] = action
        if label != nil {
            params["el"] = label!
        }
        if value != nil {
            params["ev"] = value!
        }
        return params
    }
}

public struct ExceptionHit: Hit {
    let description: String
    let fatal: Bool?
    
    var fatalString: String? {
        if fatal == nil { return nil }
        if fatal! {
            return "1"
        } else {
            return "0"
        }
    }
    
    init(description: String, fatal: Bool?) {
        self.description = description
        self.fatal = fatal
    }
    
    var params: [String: String] {
        var params = [String: String]()
        params["t"] = "exception"
        params["exd"] = description
        if fatal != nil {
            params["exf"] = fatalString!
        }
        return params
    }
}

