import Cocoa
import QuartzCore

// TODO: Replace this with `NSSwitch` when targeting macOS 10.15.

final class IOSSwitch: NSControl {
	let animationDuration: CFTimeInterval = 0.4

	let borderLineWidth: CGFloat = 2

	let goldenRatio: CGFloat = 1.618_033_988_75
	let decreasedGoldenRatio: CGFloat = 1.38

	let enabledOpacity: Float = 1
	let disabledOpacity: Float = 0.5

	let knobBackgroundColor = NSColor(calibratedWhite: 1, alpha: 1)

	let disabledBorderColor = NSColor(calibratedRed: 0.84, green: 0.85, blue: 0.87, alpha: 1)
	let disabledBackgroundColor = NSColor(calibratedRed: 0.84, green: 0.85, blue: 0.87, alpha: 1)
	let defaultTintColor = NSColor(calibratedRed: 0.27, green: 0.62, blue: 1, alpha: 1)
	let inactiveBackgroundColor = NSColor(calibratedWhite: 0, alpha: 0.3)

	var isActive = false
	var hasDragged = false
	var isDraggingTowardsOn = false

	let rootLayer = CALayer()
	let backgroundLayer = CALayer()
	let knobLayer = CALayer()
	let knobInsideLayer = CALayer()

	var on = false {
		didSet {
			reloadLayer()
		}
	}

	var tintColor: NSColor {
		get { tintColorStore ?? defaultTintColor }
		set {
			tintColorStore = newValue
		}
	}

	var tintColorStore: NSColor? {
		didSet {
			reloadLayer()
		}
	}

	override var isEnabled: Bool {
		didSet {
			reloadLayer()
		}
	}

	// MARK: Init

	required init?(coder: NSCoder) {
		super.init(coder: coder)

		setup()
	}

	override init(frame frameRect: CGRect) {
		super.init(frame: frameRect)

		setup()
	}

	func setup() {
		// The Switch is enabled per default
		isEnabled = true

		// Set up the layer hierarchy
		setUpLayers()
	}

	func setUpLayers() {
		// Root layer
		// rootLayer.delegate = self
		layer = rootLayer
		wantsLayer = true

		// Background layer
		backgroundLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
		backgroundLayer.bounds = rootLayer.bounds
		backgroundLayer.anchorPoint = CGPoint(x: 0, y: 0)
		backgroundLayer.borderWidth = borderLineWidth
		rootLayer.addSublayer(backgroundLayer)

		// Knob layer
		knobLayer.frame = rectForKnob()
		knobLayer.autoresizingMask = .layerHeightSizable
		knobLayer.backgroundColor = knobBackgroundColor.cgColor
		knobLayer.shadowColor = NSColor.black.cgColor
		knobLayer.shadowOffset = CGSize(width: 0, height: -2)
		knobLayer.shadowRadius = 1
		knobLayer.shadowOpacity = 0.3
		rootLayer.addSublayer(knobLayer)

		knobInsideLayer.frame = knobLayer.bounds
		knobInsideLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
		knobInsideLayer.shadowColor = NSColor.black.cgColor
		knobInsideLayer.shadowOffset = CGSize(width: 0, height: 0)
		knobInsideLayer.backgroundColor = NSColor.white.cgColor
		knobInsideLayer.shadowRadius = 1
		knobInsideLayer.shadowOpacity = 0.35
		knobLayer.addSublayer(knobInsideLayer)

		// Initial
		reloadLayerSize()
		reloadLayer()
	}

	// MARK: NSView

	override func acceptsFirstMouse(for theEvent: NSEvent?) -> Bool { true }

	override var frame: CGRect {
		didSet {
			reloadLayerSize()
		}
	}

	// MARK: Update Layer

	func reloadLayer() {
		CATransaction.begin()
		CATransaction.setAnimationDuration(animationDuration)


		// ------------------------------- Animate Border
		// The green part also animates, which looks kinda weird
		// We'll use the background-color for now
		//		  _backgroundLayer.borderWidth = (YES || self.isActive || self.isOn) ? NSHeight(_backgroundLayer.bounds) / 2 : kBorderLineWidth;

		// ------------------------------- Animate Colors
		if (hasDragged && isDraggingTowardsOn) || (!hasDragged && on) {
			backgroundLayer.borderColor = tintColor.cgColor
			backgroundLayer.backgroundColor = tintColor.cgColor
		} else {
			backgroundLayer.borderColor = disabledBorderColor.cgColor
			backgroundLayer.backgroundColor = disabledBackgroundColor.cgColor
		}

		// ------------------------------- Animate Enabled-Disabled state
		if isEnabled {
			rootLayer.opacity = enabledOpacity
		} else {
			rootLayer.opacity = disabledOpacity
		}

		// ------------------------------- Animate Frame
		if !hasDragged {
			let function = CAMediaTimingFunction(controlPoints: 0.25, 1.5, 0.5, 1)
			CATransaction.setAnimationTimingFunction(function)
		}

		knobLayer.frame = rectForKnob()
		knobInsideLayer.frame = knobLayer.bounds

		CATransaction.commit()
	}

	func reloadLayerSize() {
		CATransaction.begin()
		CATransaction.setDisableActions(true)

		knobLayer.frame = rectForKnob()
		knobInsideLayer.frame = knobLayer.bounds

		backgroundLayer.cornerRadius = backgroundLayer.bounds.size.height / 2
		knobLayer.cornerRadius = knobLayer.bounds.size.height / 2
		knobInsideLayer.cornerRadius = knobLayer.bounds.size.height / 2

		CATransaction.commit()
	}


	func rectForKnob() -> CGRect {
		let knobHeight = knobHeightForSize(backgroundLayer.bounds.size)
		let knobWidth = knobWidthForSize(backgroundLayer.bounds.size)
		let knobX = knobXForSize(backgroundLayer.bounds.size, knobWidth: knobWidth)
		return CGRect(x: knobX, y: borderLineWidth, width: knobWidth, height: knobHeight)
	}


	func knobHeightForSize(_ size: CGSize) -> CGFloat {
		size.height - (borderLineWidth * 2)
	}

	func knobWidthForSize(_ size: CGSize) -> CGFloat {
		if isActive {
			return (size.width - (2 * borderLineWidth)) * (1 / decreasedGoldenRatio)
		} else {
			return (size.width - (2 * borderLineWidth)) * (1 / goldenRatio)
		}
	}

	func knobXForSize(_ size: CGSize, knobWidth: CGFloat) -> CGFloat {
		if (!hasDragged && !on) || (hasDragged && !isDraggingTowardsOn) {
			return borderLineWidth
		} else {
			return size.width - knobWidth - borderLineWidth
		}
	}

	// MARK: NSResponder

	override var acceptsFirstResponder: Bool { true }

	override func mouseDown(with theEvent: NSEvent) {
		guard isEnabled else {
			return
		}

		isActive = true

		reloadLayer()
	}

	override func mouseDragged(with theEvent: NSEvent) {
		guard isEnabled else {
			return
		}

		hasDragged = true

		let draggingPoint = convert(theEvent.locationInWindow, from: nil)
		isDraggingTowardsOn = draggingPoint.x >= bounds.size.width / 2

		reloadLayer()
	}

	override func mouseUp(with theEvent: NSEvent) {
		guard isEnabled else {
			return
		}

		isActive = false

		let newOnValue: Bool
		if !hasDragged {
			newOnValue = !on
		} else {
			newOnValue = isDraggingTowardsOn
		}
		let shouldInvokeTargetAction = on != newOnValue

		on = newOnValue

		if shouldInvokeTargetAction {
			invokeTargetAction()
		}

		// Reset
		hasDragged = false
		isDraggingTowardsOn = false

		reloadLayer()
	}

	// MARK: Helpers

	func invokeTargetAction() {
		if
			let target = self.target,
			let action = self.action
		{
			sendAction(action, to: target)
		}
	}
}
