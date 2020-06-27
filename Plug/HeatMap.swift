import Cocoa
import HypeMachineAPI

final class HeatMap {
	var track: HypeMachineAPI.Track
	var start: Double
	var end: Double

	init(track: HypeMachineAPI.Track, start: Double, end: Double) {
		self.track = track
		self.start = start
		self.end = end
	}
}
