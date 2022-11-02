import Cocoa

final class PostInfoTextField: NSTextField {
	var postInfoDelegate: PostInfoTextFieldDelegate?

	private var trackingArea: NSTrackingArea?
	private var isMouseInside = false

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		updateTrackingAreas()
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if let trackingArea {
			removeTrackingArea(trackingArea)
			self.trackingArea = nil
		}

		let options: NSTrackingArea.Options = [
			.inVisibleRect,
			.activeAlways,
			.mouseEnteredAndExited
		]
		trackingArea = NSTrackingArea(rect: .zero, options: options, owner: self, userInfo: nil)
		addTrackingArea(trackingArea!)
	}

	override func mouseDown(with theEvent: NSEvent) {
		postInfoDelegate?.postInfoTextFieldClicked(self)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		isMouseInside = true
		updateText()
	}

	override func mouseExited(with theEvent: NSEvent) {
		isMouseInside = false
		updateText()
	}

	private func updateText() {
		if isMouseInside {
			let contents = NSMutableAttributedString(attributedString: attributedStringValue)
			contents.enumerateAttribute(.link, in: NSRange(location: 0, length: contents.length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
				if value != nil {
					contents.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
				}
			}

			attributedStringValue = contents
		} else {
			let contents = NSMutableAttributedString(attributedString: attributedStringValue)
			contents.enumerateAttribute(.link, in: NSRange(location: 0, length: contents.length), options: .longestEffectiveRangeNotRequired) { value, range, _ in
				if value != nil {
					contents.addAttribute(.underlineStyle, value: 0, range: range)
				}
			}

			attributedStringValue = contents
		}
	}
}

protocol PostInfoTextFieldDelegate {
	func postInfoTextFieldClicked(_ sender: AnyObject)
}
