//
//  SimpleGoogleAnalytics.swift
//  Alex Marchant
//
//  Created by Alex Marchant on 10/10/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation
import Alamofire

// MARK: - Dictionary#merge

extension Dictionary /* <KeyType, ValueType> */ {
    func merge(dictionary: Dictionary<Key, Value>) -> Dictionary {
        var newDictionary = self
        for key in dictionary.keys {
            if newDictionary[key] != nil { continue }
            newDictionary[key] = dictionary[key]
        }
        return newDictionary
    }
}

// MARK: -

public class Manager: NSObject {
    let trackingID: String
    let userID: String?
    let apiBase = "https://ssl.google-analytics.com/collect"
    let GAClientIDKey = "GAClientIDKey"
    
    var requestManager: Alamofire.Manager!
    
    public init(trackingID: String, userID: String?) {
        self.trackingID = trackingID
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
    
    public func trackEvent(#category: String, action: String, label: String?, value: String?) {
        let hit = EventHit(category: category, action: action, label: label, value: value)
        sendHit(hit)
    }
    
    func sendHit(hit: Hit) {
        let hitParams = hit.params()
        let params = defaultParams().merge(hitParams)
        requestManager.request(.POST, apiBase, parameters: params)
            .response { (_, _, _, error) in
                println(error)
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
        var newUUID = CFUUIDCreate(nil)
        var string = CFUUIDCreateString(nil, newUUID) as String
        return string
    }
    
    private func appName() -> String {
        return NSBundle(forClass: self.dynamicType).objectForInfoDictionaryKey(kCFBundleNameKey as String) as! String
    }
    
    private func appVersion() -> String {
        return NSBundle(forClass: self.dynamicType).objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }
    
    private func appID() -> String {
        return NSBundle(forClass: self.dynamicType).bundleIdentifier!
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
        let lang = NSLocale.preferredLanguages()[0] as! String
        let identifer = lang == "en" ? "en_US" : lang
        let locale = NSLocale(localeIdentifier: identifer)
        return "\(locale.objectForKey(NSLocaleLanguageCode)!)-\(locale.objectForKey(NSLocaleCountryCode)!)"
    }
}

// MARK: - Hit Protocol

protocol Hit {
    func description() -> String
    func params() -> [String: String]
}

public struct ScreenviewHit: Hit {
    var viewName: String
    var contentDescription: String {
        return viewName
    }
    
    init(viewName: String) {
        self.viewName = viewName
    }
    
    func description() -> String {
        return "<ScreenviewHit viewName: \(viewName)>"
    }
    
    func params() -> [String: String] {
        return [
            "t": "screenview",
            "cd": contentDescription,
        ]
    }
}

public struct EventHit: Hit {
    var category: String
    var action: String
    var label: String?
    var value: String?
    
    init(category: String, action: String, label: String?, value: String?) {
        self.category = category
        self.action = action
        self.label = label
        self.value = value
    }
    
    func description() -> String {
        return "<EventHit category: \(category), action: \(action), label: \(label), value: \(value)>"
    }
    
    func params() -> [String: String] {
        var params = [String: String]()
        params["t"] = "event"
        params["ec"] = category
        params["ea"] = action
        if label != nil {
            params["el"] = label
        }
        if value != nil {
            params["ev"] = value
        }
        return params
    }
}

