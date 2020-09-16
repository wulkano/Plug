import Cocoa
import Alamofire

final class HeatMapTrackTableCellView: TrackTableCellView {
	var heatMapView: HeatMapView!

	override func objectValueChanged() {
		super.objectValueChanged()

		guard objectValue != nil else {
			return
		}

		updateHeatMap()
	}

	override func mouseInsideChanged() {
		super.mouseInsideChanged()
		updateHeatMapVisibility()
	}

	override func playStateChanged() {
		super.playStateChanged()
		updateHeatMapVisibility()
	}

	private func updateHeatMap() {
		heatMapView.heatMap = nil
		let originalTrackID = track.id

		Alamofire
			.request("https://www.plugformac.com/data/heatmaps.json", method: .get)
			.validate()
			.responseJSON { [weak self] response in
				guard
					let self = self,
					self.objectValue != nil,
					self.track.id == originalTrackID
				else {
					return
				}

				switch response.result {
				case .success(let JSON):
					if
						let representation = JSON as? [String: Any],
						let trackJSON = representation[self.track.id] as? [String: Any]
					{
						let startPoint = (trackJSON["beginningValue"]! as! NSNumber).doubleValue
						let endPoint = (trackJSON["endValue"]! as! NSNumber).doubleValue
						let heatMap = HeatMap(track: self.track, start: startPoint, end: endPoint)
						self.heatMapView.heatMap = heatMap
					} else {
						// print("Heatmap missed for track: \(self.trackValue)")
					}
				case .failure(let error):
					// TODO: Show error to the user.
					print(error)
				}
			}
	}

	private func updateHeatMapVisibility() {
		heatMapView.isHidden = !playPauseButton.isHidden
	}
}
