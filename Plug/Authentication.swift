import Foundation

struct Authentication {
	fileprivate static let usernameHashKey = "WGmV6YEF9VFZBjcx"

	static func userSignedIn() -> Bool {
		!(getUsername() == nil || getToken() == nil)
	}

	static func getUsername() -> String? {
		UserDefaults.standard.value(forKey: "username") as? String
	}

	static func getToken() -> String? {
		guard
			let username = UserDefaults.standard.value(forKey: "username") as? String
		else {
			return nil
		}

		return SSKeychain.password(forService: tokenServiceName(), account: username)
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
		guard let username = getUsername() else {
			return nil
		}

		return username.digest(.sha1, key: usernameHashKey)
	}

	fileprivate static func tokenServiceName() -> String {
		"\(AppMeta.id).AccountToken"
	}
}
