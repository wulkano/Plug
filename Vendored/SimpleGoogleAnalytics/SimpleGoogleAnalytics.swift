import Foundation
import Alamofire

// swiftlint:disable discouraged_optional_boolean

public final class Manager {
	let trackingID: String
	let appBundle: Bundle
	let userID: String?
	let apiBase = "https://ssl.google-analytics.com/collect"
	let GAClientIDKey = "GAClientIDKey"

	var sessionManager: Alamofire.SessionManager!

	public init(trackingID: String, appBundle: Bundle, userID: String?) {
		self.trackingID = trackingID
		self.appBundle = appBundle
		self.userID = userID

		setupSessionManager()
	}

	func setupSessionManager() {
		var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
		defaultHeaders["User-Agent"] = userAgent()

		let configuration = URLSessionConfiguration.default
		configuration.httpAdditionalHeaders = defaultHeaders

		sessionManager = Alamofire.SessionManager(configuration: configuration)
	}

	func userAgent() -> String {
		let osInfo = NSDictionary(contentsOfFile: "/System/Library/CoreServices/SystemVersion.plist")!
		let currentLocale = Locale.autoupdatingCurrent
		let productName = osInfo["ProductName"] as! String
		let productVersion = (osInfo["ProductVersion"] as! String).replacingOccurrences(of: ".", with: "_")
		let language = (currentLocale as NSLocale).object(forKey: NSLocale.Key.languageCode) as! String
		let country = (currentLocale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
		return "GoogleAnalytics/2.0 (Macintosh; Intel \(productName) \(productVersion); \(language)-\(country))"
	}

	public func trackPageview(_ viewName: String) {
		let hit = ScreenviewHit(viewName: viewName)
		sendHit(hit)
	}

	public func trackEvent(category: String, action: String, label: String?, value: String?) {
		let hit = EventHit(category: category, action: action, label: label, value: value)
		sendHit(hit)
	}

	public func trackException(description: String, fatal: Bool?) {
		let hit = ExceptionHit(description: description, fatal: fatal)
		sendHit(hit)
	}

	func sendHit(_ hit: Hit) {
		let hitParams = hit.params
		let params = defaultParams().merge(hitParams)

		sessionManager.request(apiBase, method: .post, parameters: params)
			.response { response in
				if let error = response.error {
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
			"ul": userLanguage()
		]

		if let uid = userID {
			params["uid"] = uid
		}

		return params
	}

	private func version() -> String { "1" }

	private func clientID() -> String {
		if let UUID = UserDefaults.standard.string(forKey: GAClientIDKey) {
			return UUID
		} else {
			let newUUID = generateClientID()
			UserDefaults.standard.set(newUUID, forKey: GAClientIDKey)
			return newUUID
		}
	}

	private func generateClientID() -> String {
		let newUUID = CFUUIDCreate(nil)
		let string = CFUUIDCreateString(nil, newUUID) as String
		return string
	}

	private func appName() -> String {
		appBundle.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
	}

	private func appVersion() -> String {
		appBundle.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
	}

	private func appID() -> String {
		appBundle.bundleIdentifier!
	}

	private func screenResolution() -> String {
		let size = (NSScreen.main!.deviceDescription[NSDeviceDescriptionKey.size]! as AnyObject).sizeValue

		let width = Int(size!.width)
		let height = Int(size!.height)
		return "\(width)x\(height)"
	}

	private func screenColors() -> String {
		let bits = NSScreen.main!.depth.bitsPerPixel
		return "\(bits)-bit"
	}

	private func userLanguage() -> String {
		let locale = Locale.current
		return "\((locale as NSLocale).object(forKey: NSLocale.Key.languageCode)!)-\((locale as NSLocale).object(forKey: NSLocale.Key.countryCode)!)"
	}
}

// MARK: - Hit Protocol

protocol Hit {
	var description: String { get }
	var params: [String: String] { get }
}

public struct ScreenviewHit: Hit {
	let viewName: String
	var contentDescription: String { viewName }

	init(viewName: String) {
		self.viewName = viewName
	}

	var description: String { "<ScreenviewHit viewName: \(viewName)>" }

	var params: [String: String] {
		[
			"t": "screenview",
			"cd": contentDescription
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
		"<EventHit category: \(category), action: \(action), label: \(String(describing: label)), value: \(String(describing: value))>"
	}

	var params: [String: String] {
		var parameters = [String: String]()
		parameters["t"] = "event"
		parameters["ec"] = category
		parameters["ea"] = action

		if let label = label {
			parameters["el"] = label
		}

		if let value = value {
			parameters["ev"] = value
		}

		return parameters
	}
}

public struct ExceptionHit: Hit {
	let description: String
	let fatal: Bool?

	var fatalString: String? {
		guard let fatal = fatal else {
			return nil
		}

		return fatal ? "1" : "0"
	}

	init(description: String, fatal: Bool?) {
		self.description = description
		self.fatal = fatal
	}

	var params: [String: String] {
		var parameters = [String: String]()

		parameters["t"] = "exception"
		parameters["exd"] = description

		if fatal != nil {
			parameters["exf"] = fatalString!
		}

		return parameters
	}
}

// swiftlint:enable discouraged_optional_boolean
