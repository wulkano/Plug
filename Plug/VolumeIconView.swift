import Cocoa

final class VolumeIconView: NSView {
	@IBInspectable var offImage: NSImage?
	@IBInspectable var oneImage: NSImage?
	@IBInspectable var twoImage: NSImage?
	@IBInspectable var threeImage: NSImage?

	var volumeState = VolumeState.three {
		didSet {
			needsDisplay = true
		}
	}

	@objc dynamic var volume = 1.0 {
		didSet {
			setStateForVolume(volume)
		}
	}

	let opacity = 0.4

	override func draw(_ dirtyRect: CGRect) {
		super.draw(dirtyRect)

		guard let drawImage = getDrawImage()?.tinted(color: .labelColor) else {
			return
		}

		var drawPoint = CGPoint.zero
		drawPoint.y = floor((bounds.size.height - drawImage.size.height) / 2)

		drawImage.draw(
			at: drawPoint,
			from: bounds,
			operation: .destinationOver,
			fraction: opacity
		)
	}

	func setStateForVolume(_ volume: Double) {
		let newVolumeState: VolumeState = if volume <= 0 {
			.off
		} else if volume <= (1 / 3) {
			.one
		} else if volume <= (2 / 3) {
			.two
		} else {
			.three
		}

		// Avoid redraws if no change
		if volumeState != newVolumeState {
			volumeState = newVolumeState
		}
	}

	func getDrawImage() -> NSImage? {
		switch volumeState {
		case .off:
			offImage
		case .one:
			oneImage
		case .two:
			twoImage
		case .three:
			threeImage
		}
	}

	enum VolumeState {
		case off
		case one
		case two
		case three
	}
}
