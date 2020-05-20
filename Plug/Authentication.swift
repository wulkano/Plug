//
//	Authentication.swift
//	Plug
//
//	Created by Alex Marchant on 8/22/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

struct Authentication {
	fileprivate static let usernameHashKey = "WGmV6YEF9VFZBjcx"

	static func userSignedIn() -> Bool {
		if getUsername() == nil || getToken() == nil {
			return false
		} else {
			return true
		}
	}

	static func getUsername() -> String? {
		UserDefaults.standard.value(forKey: "username") as? String
	}

	static func getToken() -> String? {
		let username = UserDefaults.standard.value(forKey: "username") as? String
		if username == nil { return nil }

		return SSKeychain.password(forService: tokenServiceName(), account: username!)
	}

	static func saveUsername(_ username: String, withToken token: String) {
		UserDefaults.standard.setValue(username, forKey: "username")
		SSKeychain.setPassword(token, forService: tokenServiceName(), account: username)
	}

	static func deleteUsernameAndToken() {
		let username = getUsername()
		SSKeychain.deletePassword(forService: tokenServiceName(), account: username!)
		UserDefaults.standard.removeObject(forKey: "username")
	}

	static func getUsernameHash() -> String? {
		if let username = getUsername() {
			return username.digest(.sha1, key: usernameHashKey)
		} else {
			return nil
		}
	}

	fileprivate static func tokenServiceName() -> String {
		let bundleID = Bundle.main.bundleIdentifier!
		return "\(bundleID).AccountToken"
	}
}
