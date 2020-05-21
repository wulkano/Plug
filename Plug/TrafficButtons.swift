import Foundation

final class TrafficButtons {
	var closeButton: INWindowButton!
	var minimizeButton: INWindowButton!
	var zoomButton: INWindowButton!

	let buttonSize = CGSize(width: 14, height: 16)

	init(style: TrafficButtonStyle, groupIdentifier: String) {
		self.closeButton = INWindowButton(size: buttonSize, groupIdentifier: groupIdentifier)
		setupImagesForButton(&closeButton, buttonName: "close", style: style)

		self.minimizeButton = INWindowButton(size: buttonSize, groupIdentifier: groupIdentifier)
		setupImagesForButton(&minimizeButton, buttonName: "minimize", style: style)

		self.zoomButton = INWindowButton(size: buttonSize, groupIdentifier: groupIdentifier)
		setupImagesForButton(&zoomButton, buttonName: "zoom", style: style)
	}

	func addButtonsToWindow(_ window: NSWindow, origin: CGPoint) {
		hideDefaultButtons(window)
		placeButtonsInWindow(window, origin: origin)
		setupButtonActionsForWindow(window)
	}

	private func setupImagesForButton(_ button: inout INWindowButton!, buttonName: String, style: TrafficButtonStyle) {
		button.activeImage = NSImage(named: "traffic-\(buttonName)-\(style.stringValue())")
		button.activeNotKeyWindowImage = NSImage(named: "traffic-disabled-\(style.stringValue())")
		button.inactiveImage = NSImage(named: "traffic-disabled-\(style.stringValue())")
		button.rolloverImage = NSImage(named: "traffic-\(buttonName)-hover-\(style.stringValue())")
		button.pressedImage = NSImage(named: "traffic-\(buttonName)-down-\(style.stringValue())")
	}

	private func hideDefaultButtons(_ window: NSWindow) {
		window.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = true
		window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)!.isHidden = true
		window.standardWindowButton(NSWindow.ButtonType.zoomButton)!.isHidden = true
	}

	private func placeButtonsInWindow(_ window: NSWindow, origin: CGPoint) {
		let contentView = window.contentView!

		var buttonOrigin = origin
		addButton(closeButton, toView: contentView, origin: buttonOrigin)

		buttonOrigin = CGPoint(x: buttonOrigin.x + 20, y: buttonOrigin.y)
		addButton(minimizeButton, toView: contentView, origin: buttonOrigin)

		buttonOrigin = CGPoint(x: buttonOrigin.x + 20, y: buttonOrigin.y)
		addButton(zoomButton, toView: contentView, origin: buttonOrigin)
	}

	private func addButton(_ button: INWindowButton, toView superview: NSView, origin: CGPoint) {
		button.translatesAutoresizingMaskIntoConstraints = false
		superview.addSubview(button)

		var constraints = NSLayoutConstraint.constraints(withVisualFormat: "|-\(origin.x)-[button]", options: [], metrics: nil, views: ["button": button])
		superview.addConstraints(constraints)
		constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(origin.y)-[button]", options: [], metrics: nil, views: ["button": button])
		superview.addConstraints(constraints)
		constraints = NSLayoutConstraint.constraints(withVisualFormat: "[button(\(buttonSize.width))]", options: [], metrics: nil, views: ["button": button])
		superview.addConstraints(constraints)
		constraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[button(\(buttonSize.height))]", options: [], metrics: nil, views: ["button": button])
		superview.addConstraints(constraints)
	}

	private func setupButtonActionsForWindow(_ window: NSWindow) {
		closeButton.target = window
		closeButton.action = #selector(window.close)

		minimizeButton.target = window
		minimizeButton.action = #selector(window.miniaturize)

		zoomButton.target = window
		zoomButton.action = #selector(window.zoom)
	}
}

enum TrafficButtonStyle {
	case dark
	case light

	func stringValue() -> String {
		switch self {
		case .dark:
			return "dark"
		case .light:
			return "light"
		}
	}
}
