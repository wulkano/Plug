import Cocoa

// swiftlint:disable:next final_class
class LoveCountTrackTableCellView: TrackTableCellView {
	var loveCount: ColorChangingTextField!

	override func objectValueChanged() {
		super.objectValueChanged()

		guard objectValue != nil else {
			return
		}

		updateLoveCount()
	}

	override func mouseInsideChanged() {
		super.mouseInsideChanged()
		updateLoveCountVisibility()
	}

	override func playStateChanged() {
		super.playStateChanged()
		updateLoveCountVisibility()
	}

	private func updateLoveCount() {
		guard let track else {
			return
		}

		loveCount.objectValue = track.lovedCountNum
	}

	private func updateLoveCountVisibility() {
		loveCount.isHidden = !playPauseButton.isHidden
	}
}
