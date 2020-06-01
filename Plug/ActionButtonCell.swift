import Cocoa

final class ActionButtonCell: SwissArmyButtonCell {
	let horizontalPadding: CGFloat = 0

	private let onStateColor = NSColor(red256: 255, green256: 95, blue256: 82)
	private let offStateColor = NSColor(red256: 44, green256: 144, blue256: 251)

	private let normalLeftImage = NSImage(named: "Header-Button-Normal-Left")
	private let normalMiddleImage = NSImage(named: "Header-Button-Normal-Middle")
	private let normalRightImage = NSImage(named: "Header-Button-Normal-Right")

	private let mouseDownLeftImage = NSImage(named: "Header-Button-Tap-Left")
	private let mouseDownMiddleImage = NSImage(named: "Header-Button-Tap-Middle")
	private let mouseDownRightImage = NSImage(named: "Header-Button-Tap-Right")

	var offStateTitle: String = "" {
		didSet {
			updateTitle()
		}
	}

	var onStateTitle: String = "" {
		didSet {
			updateTitle()
		}
	}

	override var state: NSControl.StateValue {
		didSet {
			updateTitle()
		}
	}

	func updateTitle() {
		title = state == .off ? offStateTitle : onStateTitle
	}

	var formattedTitle: NSAttributedString {
		var attributes = [NSAttributedString.Key: Any]()
		attributes[.foregroundColor] = state == .off ? offStateColor : onStateColor
		attributes[.font] = appFont(size: 13, weight: .medium)
		return NSAttributedString(string: title, attributes: attributes)
	}

	override func drawBezel(withFrame frame: CGRect, in controlView: NSView) {
		if isMouseDown {
			NSDrawThreePartImage(frame, mouseDownLeftImage, mouseDownMiddleImage, mouseDownRightImage, false, .sourceOver, 1, true)
		} else {
			NSDrawThreePartImage(frame, normalLeftImage, normalMiddleImage, normalRightImage, false, .sourceOver, 1, true)
		}
	}

	override func drawTitle(_ title: NSAttributedString, withFrame frame: CGRect, in controlView: NSView) -> CGRect {
		var newFrame = frame
		newFrame.origin.y += 1
		newFrame.origin.x += horizontalPadding
		return super.drawTitle(formattedTitle, withFrame: newFrame, in: controlView)
	}
}
