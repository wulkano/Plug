import Cocoa


enum App {
	static let id = Bundle.main.bundleIdentifier!
	static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
	static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
	static let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String
}


extension CGSize {
	var cgRect: CGRect { CGRect(origin: .zero, size: self) }
}


extension NSImage {
	func tinted(color: NSColor) -> NSImage {
		// The force-cast is safe as NSImage can be copied.
		// swiftlint:disable:next force_cast
		let image = copy() as! NSImage

		image.isTemplate = false
		image.lockFocus()
		color.set()
		size.cgRect.fill(using: .sourceAtop)
		image.unlockFocus()
		return image
	}
}


extension NSAppearance {
	var isDarkMode: Bool { bestMatch(from: [.darkAqua, .aqua]) == .darkAqua }
}


/// Convenience for opening URLs.
extension URL {
	func open() {
		NSWorkspace.shared.open(self)
	}
}

extension String {
	/**
	```
	"https://sindresorhus.com".openUrl()
	```
	*/
	func openUrl() {
		URL(string: self)?.open()
	}
}


extension NSError {
	static func appError(_ message: String) -> Self {
		self.init(
			domain: "Plug.ErrorDomain",
			code: 1,
			userInfo: [
				NSLocalizedDescriptionKey: message
			]
		)
	}
}
