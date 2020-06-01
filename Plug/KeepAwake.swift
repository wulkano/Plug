import Foundation
import IOKit.pwr_mgt

final class KeepAwake: NSObject {
	static let shared = KeepAwake()

	let preventSleep = PreventSleep(
		sleepAssertionMsg: "Prevent idle sleep when playing audio.",
		sleepAssertionType: kIOPMAssertionTypeNoIdleSleep
	)!

	override fileprivate init() {
		super.init()

		initialSetup()
	}

	fileprivate func initialSetup() {
		AudioPlayer.shared.onTrackPlaying.addObserver(self, callback: { _, _ in
			if self.getUserPreference() {
				self.preventSleep.preventSleep()
			}
		})

		let whenToAllowSleep: [Swignal1Arg<Bool>] = [
			AudioPlayer.shared.onTrackPaused,
			AudioPlayer.shared.onSkipForward,
			AudioPlayer.shared.onSkipBackward
		]

		for aSignal in whenToAllowSleep {
			aSignal.addObserver(self) { _, _ in
				self.preventSleep.allowSleep()
			}
		}

		UserDefaults.standard.addObserver(self, forKeyPath: PreventIdleSleepWhenPlaying, options: NSKeyValueObservingOptions.new, context: nil)
	}

	deinit {
		preventSleep.allowSleep()
	}

	// MARK: NSKeyValueObserving

	fileprivate func getUserPreference() -> Bool {
		UserDefaults.standard.value(forKey: PreventIdleSleepWhenPlaying) as! Bool
	}

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		guard let keyPath = keyPath else {
			return
		}

		if keyPath == PreventIdleSleepWhenPlaying {
			// As the signal observers have already been set up, all we need to do here is to prevent sleep if a track is currently being played.
			if getUserPreference() && AudioPlayer.shared.isPlaying {
				preventSleep.preventSleep()
			} else if !getUserPreference() {
				preventSleep.allowSleep()
			}
		}
	}
}
