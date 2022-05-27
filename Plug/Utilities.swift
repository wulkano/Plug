import SwiftUI
import HypeMachineAPI


enum AppMeta {
	static let id = Bundle.main.bundleIdentifier!
	static let name = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
	static let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
	static let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
	static let copyright = Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as! String

	static let isFirstLaunch: Bool = {
		let key = "__hasLaunched__"

		if UserDefaults.standard.bool(forKey: key) {
			return false
		} else {
			UserDefaults.standard.set(true, forKey: key)
			return true
		}
	}()
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

private final class ActionTrampoline: NSObject {
	let action: (NSEvent) -> Void

	init(action: @escaping (NSEvent) -> Void) {
		self.action = action
	}

	@objc
	func action(sender: AnyObject) {
		action(NSApp.currentEvent!)
	}
}

extension ControlActionClosureProtocol {
	/**
	Closure version of `.action`

	```
	let button = NSButton(title: "Unicorn", target: nil, action: nil)

	button.onAction { _ in
		print("Button action")
	}
	```
	*/
	func onAction(_ action: @escaping (NSEvent) -> Void) {
		let trampoline = ActionTrampoline(action: action)
		target = trampoline
		self.action = #selector(ActionTrampoline.action(sender:))
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

/**
Binds the lifetime of object A to object B, so when B deallocates, so does A, but not before.
*/
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

extension NSToolbarItem {
	static let flexibleSpace = NSToolbarItem(itemIdentifier: .flexibleSpace)
	static let space = NSToolbarItem(itemIdentifier: .space)
	static let toggleSidebar = NSToolbarItem(itemIdentifier: .toggleSidebar)

	/**
	Add a centered title to the toolbar.

	- Important: Make sure to put a `.flexibleSpace` before and after it.
	*/
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

	func jpegData(compressionQuality: Double) -> Data? {
		representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
	}
}

extension Data {
	var bitmap: NSBitmapImageRep? { NSBitmapImageRep(data: self) }
}

extension NSImage {
	/**
	UIKit polyfill.
	*/
	func pngData() -> Data? {
		tiffRepresentation?.bitmap?.pngData()
	}

	/**
	UIKit polyfill.
	*/
	func jpegData(compressionQuality: CGFloat) -> Data? { // swiftlint:disable:this no_cgfloat
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


extension NSAlert {
	/**
	Show an alert as a window-modal sheet, or as an app-modal (window-indepedendent) alert if the window is `nil` or not given.
	*/
	@discardableResult
	static func showModal(
		for window: NSWindow? = nil,
		title: String,
		message: String? = nil,
		style: Style = .warning,
		buttonTitles: [String] = [],
		defaultButtonIndex: Int? = nil
	) -> NSApplication.ModalResponse {
		NSAlert(
			title: title,
			message: message,
			style: style,
			buttonTitles: buttonTitles,
			defaultButtonIndex: defaultButtonIndex
		).runModal(for: window)
	}

	/**
	The index in the `buttonTitles` array for the button to use as default.

	Set `-1` to not have any default. Useful for really destructive actions.
	*/
	var defaultButtonIndex: Int {
		get {
			buttons.firstIndex { $0.keyEquivalent == "\r" } ?? -1
		}
		set {
			// Clear the default button indicator from other buttons.
			for button in buttons where button.keyEquivalent == "\r" {
				button.keyEquivalent = ""
			}

			if newValue != -1 {
				buttons[newValue].keyEquivalent = "\r"
			}
		}
	}

	convenience init(
		title: String,
		message: String? = nil,
		style: Style = .warning,
		buttonTitles: [String] = [],
		defaultButtonIndex: Int? = nil
	) {
		self.init()
		self.messageText = title
		self.alertStyle = style

		if let message = message {
			self.informativeText = message
		}

		addButtons(withTitles: buttonTitles)

		if let defaultButtonIndex = defaultButtonIndex {
			self.defaultButtonIndex = defaultButtonIndex
		}
	}

	/**
	Runs the alert as a window-modal sheet, or as an app-modal (window-indepedendent) alert if the window is `nil` or not given.
	*/
	@discardableResult
	func runModal(for window: NSWindow? = nil) -> NSApplication.ModalResponse {
		guard let window = window else {
			return runModal()
		}

		beginSheetModal(for: window) { returnCode in
			NSApp.stopModal(withCode: returnCode)
		}

		return NSApp.runModal(for: window)
	}

	/**
	Adds buttons with the given titles to the alert.
	*/
	func addButtons(withTitles buttonTitles: [String]) {
		for buttonTitle in buttonTitles {
			addButton(withTitle: buttonTitle)
		}
	}
}


extension Dictionary {
	/**
	Adds the elements of the given dictionary to a copy of self and returns that.

	Identical keys in the given dictionary overwrites keys in the copy of self.

	- Note: This exists as an addition to `+` as Swift sometimes struggle to infer the type of `dict + dict`.
	*/
	func appending(_ dictionary: [Key: Value]) -> [Key: Value] {
		var newDictionary = self

		for (key, value) in dictionary {
			newDictionary[key] = value
		}

		return newDictionary
	}
}


extension Error {
	var isNsError: Bool { Self.self is NSError.Type }
}


extension NSError {
	static func from(error: Error, userInfo: [String: Any] = [:]) -> NSError {
		let nsError = error as NSError

		// Since Error and NSError are often bridged between each other, we check if it was originally an NSError and then return that.
		guard !error.isNsError else {
			guard !userInfo.isEmpty else {
				return nsError
			}

			return nsError.appending(userInfo: userInfo)
		}

		var userInfo = userInfo
		userInfo[NSLocalizedDescriptionKey] = error.localizedDescription

		// Awful, but no better way to get the enum case name.
		// This gets `Error.generateFrameFailed` from `Error.generateFrameFailed(Error Domain=AVFoundationErrorDomain Code=-11832 […]`.
		let errorName = "\(error)".split(separator: "(").first ?? ""

		return .init(
			domain: "\(AppMeta.id) - \(nsError.domain)\(errorName.isEmpty ? "" : ".")\(errorName)",
			code: nsError.code,
			userInfo: userInfo
		)
	}

	/**
	Returns a new error with the user info appended.
	*/
	func appending(userInfo newUserInfo: [String: Any]) -> Self {
		Self(
			domain: domain,
			code: code,
			userInfo: userInfo.appending(newUserInfo)
		)
	}
}


extension Dictionary {
	func compactValues<T>() -> [Key: T] where Value == T? {
		// TODO: Make this `compactMapValues(\.self)` when https://github.com/apple/swift/issues/55343 is fixed.
		compactMapValues { $0 }
	}
}


typealias QueryDictionary = [String: String]

extension CharacterSet {
	/**
	Characters allowed to be unescaped in an URL.

	https://tools.ietf.org/html/rfc3986#section-2.3
	*/
	static let urlUnreservedRFC3986 = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
}

/**
This should really not be necessary, but it's at least needed for my `formspree.io` form...

Otherwise is results in "Internal Server Error" after submitting the form

Relevant: https://www.djackson.org/why-we-do-not-use-urlcomponents/
*/
private func escapeQueryComponent(_ query: String) -> String {
	query.addingPercentEncoding(withAllowedCharacters: .urlUnreservedRFC3986)!
}

// TODO: This could probably be `extension Dictionary where Key: ExpressibleByStringLiteral {
extension Dictionary where Key == String {
	/**
	This correctly escapes items. See `escapeQueryComponent`.
	*/
	var toQueryItems: [URLQueryItem] {
		map {
			URLQueryItem(
				name: escapeQueryComponent($0),
				value: escapeQueryComponent("\($1)")
			)
		}
	}

	var toQueryString: String {
		var components = URLComponents()
		components.queryItems = toQueryItems
		return components.query!
	}
}

extension URLComponents {
	/**
	This correctly escapes items. See `escapeQueryComponent`.
	*/
	init?(string: String, query: QueryDictionary) {
		self.init(string: string)
		self.queryDictionary = query
	}

	/**
	This correctly escapes items. See `escapeQueryComponent`.
	*/
	var queryDictionary: QueryDictionary {
		get {
			queryItems?.toDictionary { ($0.name, $0.value) }.compactValues() ?? [:]
		}
		set {
			// Using `percentEncodedQueryItems` instead of `queryItems` since the query items are already custom-escaped. See `escapeQueryComponent`.
			percentEncodedQueryItems = newValue.toQueryItems
		}
	}
}

extension URL {
	init?(string: String, query: QueryDictionary) {
		guard let url = URLComponents(string: string, query: query)?.url else {
			return nil
		}

		self = url
	}

	var queryItems: [URLQueryItem] {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return []
		}

		return components.queryItems ?? []
	}

	var queryDictionary: QueryDictionary {
		guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return [:]
		}

		return components.queryDictionary
	}

	/**
	Get the value of a query item by the given key name.
	*/
	func queryItemValue(forKey key: String) -> String? {
		queryItems.first { $0.name == key }?.value
	}

	/**
	Returns `self` with the given `URLQueryItem` appended.
	*/
	func appendingQueryItem(_ queryItem: URLQueryItem) -> Self {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return self
		}

		if components.queryItems == nil {
			components.queryItems = []
		}

		components.queryItems?.append(queryItem)

		return components.url ?? self
	}

	/**
	Returns `self` with the given `name` and `value` appended if the `value` is not `nil`.
	*/
	func appendingQueryItem(name: String, value: String?) -> Self {
		guard let value = value else {
			return self
		}

		return appendingQueryItem(URLQueryItem(name: name, value: value))
	}

	/**
	Returns `self` with the given query dictionary merged in.

	The keys in the given dictionary overwrites any existing keys.
	*/
	func settingQueryItems(_ queryDictionary: QueryDictionary) -> Self {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
			return self
		}

		components.queryDictionary = components.queryDictionary.appending(queryDictionary)

		return components.url ?? self
	}
}


extension NSWorkspace {
	/**
	UIKit polyfill.

	Returns a boolean value indicating whether an app is available to handle a URL scheme.
	*/
	func canOpenURL(_ url: URL) -> Bool {
		urlForApplication(toOpen: url) != nil
	}
}


extension HypeMachineAPI.Track {
	func openInAppleMusic() {
		URL(string: "music://music.apple.com/WebObjects/MZStore.woa/wa/search")?
			.appendingQueryItem(name: "term", value: "\(title) \(artist)")
			.open()
	}
}

extension HypeMachineAPI.Track {
	func openInSpotify() {
		URL(string: "spotify://search:track:\(escapeQueryComponent("\(title) \(artist)"))")?.open()
	}
}


extension URL: ExpressibleByStringLiteral {
	/**
	Example:

	```
	let url: URL = "https://sindresorhus.com"
	```
	*/
	public init(stringLiteral value: StaticString) {
		self.init(string: "\(value)")!
	}
}

extension URL {
	/**
	Example:

	```
	URL("https://sindresorhus.com")
	```
	*/
	init(_ staticString: StaticString) {
		self.init(string: "\(staticString)")!
	}
}

// swiftlint:disable:next no_cgfloat
extension CGFloat {
	/**
	Get a Double from a CGFloat. This makes it easier to work with optionals.
	*/
	var double: Double { Double(self) }
}

extension Int {
	/**
	Get a Double from an Int. This makes it easier to work with optionals.
	*/
	var double: Double { Double(self) }
}


extension Font {
	/**
	The default system font size.
	*/
	static let systemFontSize = NSFont.systemFontSize.double

	/**
	The system font in default size.
	*/
	static func system(
		weight: Font.Weight = .regular,
		design: Font.Design = .default
	) -> Self {
		system(size: systemFontSize, weight: weight, design: design)
	}
}

extension Font {
	/**
	The default small system font size.
	*/
	static let smallSystemFontSize = NSFont.smallSystemFontSize.double

	/**
	The system font in small size.
	*/
	static func smallSystem(
		weight: Font.Weight = .regular,
		design: Font.Design = .default
	) -> Self {
		system(size: smallSystemFontSize, weight: weight, design: design)
	}
}


extension Collection {
	/**
	Returns the element at the specified index if it is within bounds, otherwise nil.
	*/
	subscript(safe index: Index) -> Element? {
		indices.contains(index) ? self[index] : nil
	}
}
