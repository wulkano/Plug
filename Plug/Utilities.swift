import Cocoa


enum AppMeta {
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


extension Sequence {
	/**
	Convert a sequence to a dictionary by mapping over the values and using the returned key as the key and the current sequence element as value.

	```
	[1, 2, 3].toDictionary { $0 }
	//=> [1: 1, 2: 2, 3: 3]
	```
	*/
	func toDictionary<Key: Hashable>(with pickKey: (Element) -> Key) -> [Key: Element] {
		var dictionary = [Key: Element]()
		for element in self {
			dictionary[pickKey(element)] = element
		}
		return dictionary
	}

	/**
	Convert a sequence to a dictionary by mapping over the elements and returning a key/value tuple representing the new dictionary element.

	```
	[(1, "a"), (2, "b")].toDictionary { ($1, $0) }
	//=> ["a": 1, "b": 2]
	```
	*/
	func toDictionary<Key: Hashable, Value>(with pickKeyValue: (Element) -> (Key, Value)) -> [Key: Value] {
		var dictionary = [Key: Value]()
		for element in self {
			let newElement = pickKeyValue(element)
			dictionary[newElement.0] = newElement.1
		}
		return dictionary
	}

	/**
	Same as the above but supports returning optional values.

	```
	[(1, "a"), (nil, "b")].toDictionary { ($1, $0) }
	//=> ["a": 1, "b": nil]
	```
	*/
	func toDictionary<Key: Hashable, Value>(with pickKeyValue: (Element) -> (Key, Value?)) -> [Key: Value?] {
		var dictionary = [Key: Value?]()
		for element in self {
			let newElement = pickKeyValue(element)
			dictionary[newElement.0] = newElement.1
		}
		return dictionary
	}
}


enum AssociationPolicy {
	case assign
	case retainNonatomic
	case copyNonatomic
	case retain
	case copy

	var rawValue: objc_AssociationPolicy {
		switch self {
		case .assign:
			return .OBJC_ASSOCIATION_ASSIGN
		case .retainNonatomic:
			return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
		case .copyNonatomic:
			return .OBJC_ASSOCIATION_COPY_NONATOMIC
		case .retain:
			return .OBJC_ASSOCIATION_RETAIN
		case .copy:
			return .OBJC_ASSOCIATION_COPY
		}
	}
}

final class ObjectAssociation<Value: Any> {
	private let defaultValue: Value
	private let policy: AssociationPolicy

	init(defaultValue: Value, policy: AssociationPolicy = .retainNonatomic) {
		self.defaultValue = defaultValue
		self.policy = policy
	}

	subscript(index: AnyObject) -> Value {
		get {
			objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? Value ?? defaultValue
		}
		set {
			objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy.rawValue)
		}
	}
}


private let bindLifetimeAssociatedObjectKey = ObjectAssociation<[AnyObject]>(defaultValue: [])

/// Binds the lifetime of object A to object B, so when B deallocates, so does A, but not before.
func bindLifetime(of object: AnyObject, to target: AnyObject) {
	var retainedObjects = bindLifetimeAssociatedObjectKey[target]
	retainedObjects.append(object)
	bindLifetimeAssociatedObjectKey[target] = retainedObjects
}


extension RangeReplaceableCollection {
	mutating func prepend(_ newElement: Element) {
		insert(newElement, at: startIndex)
	}
}

extension Collection {
	func appending(_ newElement: Element) -> [Element] {
		self + [newElement]
	}

	func prepending(_ newElement: Element) -> [Element] {
		[newElement] + self
	}
}


final class StaticToolbar: NSObject {
	private let toolbarItems: [NSToolbarItem.Identifier: NSToolbarItem]
	private let toolbarItemIdentifiers: [NSToolbarItem.Identifier]
	let toolbar = NSToolbar()

	init(_ items: [NSToolbarItem]) {
		// Handle the centered item.
		for item in items where item.itemIdentifier == .centeredTitle {
			toolbar.centeredItemIdentifier = item.itemIdentifier
		}

		// Prevents showing the toolbar overflow menu.
		for item in items {
			item.menuFormRepresentation = nil
		}

		self.toolbarItems = items.toDictionary(with: \.itemIdentifier)
		self.toolbarItemIdentifiers = items.map(\.itemIdentifier)
		super.init()
		toolbar.delegate = self
		toolbar.displayMode = .iconOnly
		bindLifetime(of: self, to: toolbar)
	}
}

extension StaticToolbar: NSToolbarDelegate {
	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		toolbarItemIdentifiers
	}

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		toolbarItemIdentifiers
	}

	func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
		toolbarItems[itemIdentifier]
	}
}

extension NSToolbar {
	static func staticToolbar(_ items: [NSToolbarItem]) -> NSToolbar {
		StaticToolbar(items).toolbar
	}
}

extension NSToolbarItem.Identifier {
	static let centeredTitle = Self("CenteredTitle")
}

@available(macOS 11, *)
extension NSToolbarItem {
	static let flexibleSpace = NSToolbarItem(itemIdentifier: .flexibleSpace)
	static let space = NSToolbarItem(itemIdentifier: .space)
	static let toggleSidebar = NSToolbarItem(itemIdentifier: .toggleSidebar)

	/// Add a centered title to the toolbar.
	/// - Important: Make sure to put a `.flexibleSpace` before and after it.
	static func centeredTitle(_ title: String) -> Self {
		let toolbarItem = self.init(itemIdentifier: .centeredTitle)
		toolbarItem.title = title
		return toolbarItem
	}

	static func centeredView(_ view: NSView) -> Self {
		let toolbarItem = self.init(itemIdentifier: .centeredTitle)
		toolbarItem.view = view
		return toolbarItem
	}

	static func view(identifier: NSToolbarItem.Identifier, view: NSView) -> Self {
		let toolbarItem = self.init(itemIdentifier: identifier)
		toolbarItem.view = view
		return toolbarItem
	}
}


extension NSBitmapImageRep {
	func pngData() -> Data? {
		representation(using: .png, properties: [:])
	}

	func jpegData(compressionQuality: CGFloat) -> Data? {
		representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
	}
}

extension Data {
	var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
	/// UIKit polyfill.
	func pngData() -> Data? {
		tiffRepresentation?.bitmap?.pngData()
	}

	/// UIKit polyfill.
	func jpegData(compressionQuality: CGFloat) -> Data? {
		tiffRepresentation?.bitmap?.jpegData(compressionQuality: compressionQuality)
	}
}


extension URL {
	var filename: String {
		get {
			assert(!hasDirectoryPath)
			return lastPathComponent
		}
		set {
			assert(!hasDirectoryPath)
			deleteLastPathComponent()
			appendPathComponent(newValue, isDirectory: false)
		}
	}
}


extension URL {
	static let defaultAppropriateForTemporaryDirectory = FileManager.default.homeDirectoryForCurrentUser

	/**
	Creates a unique temporary directory and returns the URL.

	The URL is unique for each call.

	The system ensures the directory is not cleaned up until after the app quits.

	- Parameter appropriateFor: By default, it creates the temporary directory on disk of the home directory of the users, but you can pass in a URL to make use the disk of that URL instead. This can be useful for larger files where it might be expensive to copy the file across disk boundaries. Keep in mind that there are also downsides to this. For example, if the passed in URL lives on a USB stick, it might disappear at any time as the drive might be ejected.
	*/
	static func uniqueTemporaryDirectory(
		appropriateFor: Self = defaultAppropriateForTemporaryDirectory
	) throws -> Self {
		try FileManager.default.url(
			for: .itemReplacementDirectory,
			in: .userDomainMask,
			appropriateFor: appropriateFor,
			create: true
		)
	}
}
