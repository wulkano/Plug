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


// MARK: - Action closure for controls

private var controlActionClosureProtocolAssociatedObjectKey: UInt8 = 0

protocol ControlActionClosureProtocol: NSObjectProtocol {
	var target: AnyObject? { get set }
	var action: Selector? { get set }
}

private final class ActionTrampoline<T>: NSObject {
	let action: (T) -> Void

	init(action: @escaping (T) -> Void) {
		self.action = action
	}

	@objc
	func action(sender: AnyObject) {
		// This is safe as it can only be `T`.
		// swiftlint:disable:next force_cast
		action(sender as! T)
	}
}

extension ControlActionClosureProtocol {
	/**
	Closure version of `.action`

	```
	let button = NSButton(title: "Unicorn", target: nil, action: nil)

	button.onAction { sender in
		print("Button action: \(sender)")
	}
	```
	*/
	func onAction(_ action: @escaping (Self) -> Void) {
		let trampoline = ActionTrampoline(action: action)
		target = trampoline
		self.action = #selector(ActionTrampoline<Self>.action(sender:))
		objc_setAssociatedObject(self, &controlActionClosureProtocolAssociatedObjectKey, trampoline, .OBJC_ASSOCIATION_RETAIN)
	}
}

extension NSControl: ControlActionClosureProtocol {}
extension NSMenuItem: ControlActionClosureProtocol {}
extension NSToolbarItem: ControlActionClosureProtocol {}
extension NSGestureRecognizer: ControlActionClosureProtocol {}

// MARK: -


extension NSMenuItem {
	/**
	The menu is only created when it's enabled.

	```
	menu.addItem("Foo")
		.withSubmenu(createCalendarEventMenu(with: event))
	```
	*/
	@discardableResult
	func withSubmenu(_ menu: @autoclosure () -> NSMenu) -> Self {
		submenu = isEnabled ? menu() : NSMenu()
		return self
	}

	/**
	The menu is only created when it's enabled.

	```
	menu
		.addItem("Foo")
		.withSubmenu { menu in

		}
	```
	*/
	@discardableResult
	func withSubmenu(_ menuBuilder: (NSMenu) -> NSMenu) -> Self {
		withSubmenu(menuBuilder(NSMenu()))
	}
}
