//
//  Authentication.swift
//  Plug
//
//  Created by Alex Marchant on 8/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation
import SSKeychain

struct Authentication {
    private static let UsernameHashKey = "WGmV6YEF9VFZBjcx"
    
    static func UserSignedIn() -> Bool {
        if GetUsername() == nil || GetToken() == nil {
            return false
        } else {
            return true
        }
    }
    
    static func GetUsername() -> String? {
        return NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
    }
    
    static func GetToken() -> String? {
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
        if username == nil { return nil }
        
        return SSKeychain.passwordForService(TokenServiceName(), account: username!)
    }
    
    static func SaveUsername(username: String, withToken token: String) {
        NSUserDefaults.standardUserDefaults().setValue(username, forKey: "username")
        SSKeychain.setPassword(token, forService: TokenServiceName(), account: username)
    }
    
    static func DeleteUsernameAndToken() {
        let username = GetUsername()
        SSKeychain.deletePasswordForService(TokenServiceName(), account: username!)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
    }
    
    static func GetUsernameHash() -> String? {
        if let username = GetUsername() {
            return username.digest(.SHA1, key: UsernameHashKey)
        } else {
            return nil
        }
    }
    
    private static func TokenServiceName() -> String {
        let bundleID = NSBundle.mainBundle().bundleIdentifier!
        return "\(bundleID).AccountToken"
    }
}