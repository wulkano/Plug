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
		AudioPlayer.shared.onTrackPlaying.addObserver(self) { [weak self] _, _ in
			guard let self else {
				return
			}

			if self.getUserPreference() {
				_ = self.preventSleep.preventSleep()
			}
		}

		let whenToAllowSleep: [Swignal1Arg<Bool>] = [
			AudioPlayer.shared.onTrackPaused,
			AudioPlayer.shared.onSkipForward,
			AudioPlayer.shared.onSkipBackward
		]

		for signal in whenToAllowSleep {
			signal.addObserver(self) { [weak self] _, _ in
				guard let self else {
					return
				}

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

	// TODO: Use the modern API.
	// swiftlint:disable:next block_based_kvo discouraged_optional_collection
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		guard let keyPath else {
			return
		}

		if keyPath == PreventIdleSleepWhenPlaying {
			// As the signal observers have already been set up, all we need to do here is to prevent sleep if a track is currently being played.
			if getUserPreference(), AudioPlayer.shared.isPlaying {
				_ = preventSleep.preventSleep()
			} else if !getUserPreference() {
				preventSleep.allowSleep()
			}
		}
	}
}
