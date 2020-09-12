import Cocoa

final class HyperlinkButton: NSButton {
	@IBInspectable var textColor: NSColor = .labelColor {
		didSet {
			applyAttributes()
		}
	}

	@IBInspectable var selectedTextColor: NSColor = NSColor(red256: 255, green256: 95, blue256: 82) {
		didSet {
			applyAttributes()
		}
	}

	@IBInspectable var isSelected: Bool = false {
		didSet {
			applyAttributes()
		}
	}

	@IBInspectable var hasHoverUnderline: Bool = false
	@IBInspectable var isAlwaysUnderlined: Bool = false

	override var title: String {
		didSet {
			applyAttributes()
		}
	}

	private var trackingArea: NSTrackingArea?
	private var isMouseInside = false {
		didSet {
			mouseInsideChanged()
		}
	}

	init() {
		super.init(frame: .zero)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	func setup() {
		setButtonType(.momentaryPushIn)
		bezelStyle = .rounded
	}

	func applyAttributes() {
		var attributes = [NSAttributedString.Key: Any]()
		if isSelected {
			attributes[.foregroundColor] = selectedTextColor
		} else {
			attributes[.foregroundColor] = textColor
		}
		attributes[.font] = (cell as! NSButtonCell).font
		let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
		paragraphStyle.lineBreakMode = (cell as! NSButtonCell).lineBreakMode
		attributes[.paragraphStyle] = paragraphStyle
		let coloredString = NSMutableAttributedString(string: title, attributes: attributes)
		attributedTitle = coloredString
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		updateTrackingAreas()

		if isAlwaysUnderlined {
			addUnderlineToText()
		}
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if hasHoverUnderline, !isAlwaysUnderlined {
			if trackingArea != nil {
				removeTrackingArea(trackingArea!)
				trackingArea = nil
			}

			let options: NSTrackingArea.Options = [.inVisibleRect, .activeAlways, .mouseEnteredAndExited]
			trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
			addTrackingArea(trackingArea!)
		}
	}

	override func mouseEntered(with theEvent: NSEvent) {
		isMouseInside = true
	}

	override func mouseExited(with theEvent: NSEvent) {
		isMouseInside = false
	}

	func mouseInsideChanged() {
		if isMouseInside {
			addUnderlineToText()
		} else {
			removeUnderlineFromText()
		}
	}

	func addUnderlineToText() {
		let range = NSRange(location: 0, length: attributedTitle.length)
		let newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
		newAttributedTitle.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
		attributedTitle = newAttributedTitle
	}

	func removeUnderlineFromText() {
		let range = NSRange(location: 0, length: attributedTitle.length)
		let newAttributedTitle = NSMutableAttributedString(attributedString: attributedTitle)
		newAttributedTitle.addAttribute(.underlineStyle, value: 0, range: range)
		attributedTitle = newAttributedTitle
	}
}
