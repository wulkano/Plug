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
    fileprivate static let UsernameHashKey = "WGmV6YEF9VFZBjcx"
    
    static func UserSignedIn() -> Bool {
        if GetUsername() == nil || GetToken() == nil {
            return false
        } else {
            return true
        }
    }
    
    static func GetUsername() -> String? {
        return UserDefaults.standard.value(forKey: "username") as? String
    }
    
    static func GetToken() -> String? {
        let username = UserDefaults.standard.value(forKey: "username") as? String
        if username == nil { return nil }
        
        return SSKeychain.password(forService: TokenServiceName(), account: username!)
    }
    
    static func SaveUsername(_ username: String, withToken token: String) {
        UserDefaults.standard.setValue(username, forKey: "username")
        SSKeychain.setPassword(token, forService: TokenServiceName(), account: username)
    }
    
    static func DeleteUsernameAndToken() {
        let username = GetUsername()
        SSKeychain.deletePassword(forService: TokenServiceName(), account: username!)
        UserDefaults.standard.removeObject(forKey: "username")
    }
    
    static func GetUsernameHash() -> String? {
        if let username = GetUsername() {
            return username.digest(.sha1, key: UsernameHashKey)
        } else {
            return nil
        }
    }
    
    fileprivate static func TokenServiceName() -> String {
        let bundleID = Bundle.main.bundleIdentifier!
        return "\(bundleID).AccountToken"
    }
}
