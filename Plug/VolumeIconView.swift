import Cocoa

final class VolumeIconView: NSView {
	@IBInspectable var offImage: NSImage?
	@IBInspectable var oneImage: NSImage?
	@IBInspectable var twoImage: NSImage?
	@IBInspectable var threeImage: NSImage?
	var volumeState = VolumeState.three {
		didSet { needsDisplay = true }
	}

	@objc dynamic var volume: Double = 1 {
		didSet {
			setStateForVolume(volume)
		}
	}

	var opacity: CGFloat = 0.3

	override func draw(_ dirtyRect: CGRect) {
		super.draw(dirtyRect)

		let drawImage = getDrawImage()
		var drawPoint = CGPoint.zero
		if drawImage != nil {
			drawPoint.y = floor((bounds.size.height - drawImage!.size.height) / 2)
		}
		drawImage?.draw(at: drawPoint, from: dirtyRect, operation: NSCompositingOperation.destinationOver, fraction: opacity)
	}

	func setStateForVolume(_ volume: Double) {
		var newVolumeState: VolumeState

		if volume <= 0 {
			newVolumeState = VolumeState.off
		} else if volume <= (1 / 3) {
			newVolumeState = VolumeState.one
		} else if volume <= (2 / 3) {
			newVolumeState = VolumeState.two
		} else {
			newVolumeState = VolumeState.three
		}

		// Avoid redraws if no change
		if volumeState != newVolumeState {
			volumeState = newVolumeState
		}
	}

	func getDrawImage() -> NSImage? {
		switch volumeState {
		case .off:
			return offImage
		case .one:
			return oneImage
		case .two:
			return twoImage
		case .three:
			return threeImage
		}
	}

	enum VolumeState {
		case off
		case one
		case two
		case three
	}
}
