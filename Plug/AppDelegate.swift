import Cocoa
import UserNotifications
import Sentry
import HypeMachineAPI

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
	var mainWindowController: NSWindowController?
	var loginWindowController: NSWindowController?
	var preferencesWindowController: NSWindowController?
	var aboutWindowController: AboutWindowController?
	@IBOutlet private var preferencesMenuItem: NSMenuItem!
	@IBOutlet private var preferencesMenuSeparator: NSMenuItem!
	@IBOutlet private var signOutMenuItem: NSMenuItem!
	@IBOutlet private var signOutMenuSeparator: NSMenuItem!
	@IBOutlet private var mainWindowMenuItem: NSMenuItem!

	var mainWindowObservation: NSObjectProtocol?

	deinit {
		Notifications.unsubscribeAll(observer: self)
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		assert(!Secrets.apiKey.isEmpty)
		setupUserDefaults()

		SentrySDK.start {
			$0.dsn = "https://de9821b005af4222a9fc4315040749f4@o116098.ingest.sentry.io/5245093"
		}

		UNUserNotificationCenter.current().requestAuthorization { _, _ in }
		setupNotifications()
		setupHypeMachineAPI()
		_ = KeepAwake.shared

		if Authentication.userSignedIn() {
			openMainWindow()
		} else {
			openLoginWindow()
		}

		showWelcomeScreenIfNeeded()

//		#if DEBUG
//		// For testing the error toast.
//		Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test. Lorem Ipsum."])])
//		#endif
	}

	// swiftlint:disable:next private_action
	@IBAction func mainWindowMenuItemClicked(_ sender: NSMenuItem) {
		if mainWindowController == nil || mainWindowController?.window?.isVisible == false {
			openMainWindow()
		} else {
			mainWindowController?.window?.orderOut(self)
		}
	}

	func openMainWindow() {
		if mainWindowController == nil {
			mainWindowController = (NSStoryboard(name: "Main", bundle: nil).instantiateInitialController() as! NSWindowController)

			mainWindowObservation = mainWindowController?.window?.observe(\.isVisible) { [self] window, _ in
				mainWindowMenuItem.state = window.isVisible ? .on : .off
			}

			// If there isn't an autosave name set for the main window, place the frame at a default position, and then set the autosave name.
			if mainWindowController!.windowFrameAutosaveName.isEmpty {
				let width: CGFloat = 472
				let height: CGFloat = 778
				let x: CGFloat = 100
				let y: CGFloat = (NSScreen.main!.frame.size.height - 778) / 2

				let defaultFrame = CGRect(x: x, y: y, width: width, height: height)
				mainWindowController!.window!.setFrame(defaultFrame, display: false)

				mainWindowController!.window!.setFrameAutosaveName("MainWindow")
			}
		}

		mainWindowController!.showWindow(self)
		showSignOutInMenu()
		showPreferencesInMenu()
	}

	func closeMainWindow() {
		mainWindowController!.window!.close()
		mainWindowController = nil
	}

	func openLoginWindow() {
		Analytics.trackView("LoginWindow")

		if loginWindowController == nil {
			loginWindowController = (NSStoryboard(name: "Login", bundle: nil).instantiateInitialController() as! NSWindowController)
		}

		loginWindowController!.showWindow(self)
		hideSignOutFromMenu()
		hidePreferencesFromMenu()
	}

	func closeLoginWindow() {
		loginWindowController!.window!.close()
		loginWindowController = nil
	}

	func openAboutWindow() {
		if aboutWindowController == nil {
			aboutWindowController = AboutWindowController()
		}
		aboutWindowController!.showWindow(self)
	}

	func openPreferencesWindow() {
		if preferencesWindowController == nil {
			let preferencesStoryboard = NSStoryboard(name: "Preferences", bundle: Bundle.main)
			preferencesWindowController = (preferencesStoryboard.instantiateInitialController() as! NSWindowController)
		}

		preferencesWindowController!.showWindow(self)
	}

	func closePreferencesWindow() {
		preferencesWindowController!.window!.close()
		preferencesWindowController = nil
	}

	func finishedSigningIn() {
		closeLoginWindow()
		openMainWindow()
	}

	func showPreferencesInMenu() {
		preferencesMenuItem.isHidden = false
		preferencesMenuSeparator.isHidden = false
	}

	func hidePreferencesFromMenu() {
		preferencesMenuItem.isHidden = true
		preferencesMenuSeparator.isHidden = true
	}

	func showSignOutInMenu() {
		signOutMenuItem.isHidden = false
		signOutMenuSeparator.isHidden = false
	}

	func hideSignOutFromMenu() {
		signOutMenuItem.isHidden = true
		signOutMenuSeparator.isHidden = true
	}

	func setupUserDefaults() {
		let userDefaultsValuesPath = Bundle.main.path(forResource: "UserDefaults", ofType: "plist")!
		let userDefaultsValuesDict = NSDictionary(contentsOfFile: userDefaultsValuesPath)!
		UserDefaults.standard.register(defaults: userDefaultsValuesDict as! [String: AnyObject])
	}

	func setupNotifications() {
		Notifications.subscribe(observer: self, selector: #selector(AppDelegate.catchTokenErrors(_:)), name: Notifications.DisplayError, object: nil)
	}

	func setupHypeMachineAPI() {
		HypeMachineAPI.apiKey = Secrets.apiKey
		if let hmToken = Authentication.getToken() {
			HypeMachineAPI.hmToken = hmToken
		}

		HypeMachineAPI.userAgent = "Plug for OSX/\(AppMeta.version)"
	}

	// MARK: Notifications

	@objc
	func catchTokenErrors(_ notification: Notification) {
		guard let error = notification.userInfo?["error"] as? HypeMachineAPI.APIError else {
			return
		}

		recordNonFatalError(error)

		switch error {
		// FIXME: I'm not entirely sure how this happens, but sometimes the actual error is wrapped in a network error.
		case .invalidHMToken, .network(error: HypeMachineAPI.APIError.invalidHMToken):
			signOut(nil)
		default:
			break
		}
	}

	// MARK: Actions

	@IBAction private func aboutItemClicked(_ sender: AnyObject) {
		openAboutWindow()
	}

	@IBAction private func signOut(_ sender: AnyObject?) {
		Analytics.trackButtonClick("Sign Out")
		closeMainWindow()
		if preferencesWindowController != nil {
			closePreferencesWindow()
		}
		AudioPlayer.shared.reset()
		Authentication.deleteUsernameAndToken()
		HypeMachineAPI.hmToken = nil
		openLoginWindow()
	}

	@IBAction private func preferencesItemClicked(_ sender: AnyObject) {
		openPreferencesWindow()
	}

	@IBAction private func refreshItemClicked(_ sender: AnyObject) {
		Notifications.post(name: Notifications.RefreshCurrentView, object: self, userInfo: nil)
	}

	@IBAction private func playPauseItemClicked(_ sender: NSMenuItem) {
		AudioPlayer.shared.playPauseToggle()
	}

	@IBAction private func nextTrackItemClicked(_ sender: NSMenuItem) {
		AudioPlayer.shared.skipForward()
	}

	@IBAction private func previousTrackItemClicked(_ sender: NSMenuItem) {
		AudioPlayer.shared.skipBackward()
	}

	@IBAction private func reportABugItemClicked(_ sender: AnyObject) {
		"https://sindresorhus.com/feedback/?product=Plug".openUrl()
	}

	// MARK: NSApplicationDelegate

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		!Authentication.userSignedIn()
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		if !flag {
			openMainWindow()
		}

		return true
	}
}

extension AppDelegate: NSMenuItemValidation {
	func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		switch menuItem.action {
		case #selector(playPauseItemClicked)?:
			menuItem.title = AudioPlayer.shared.isPlaying ? "Pause" : "Play"
			return AudioPlayer.shared.currentTrack != nil
		case #selector(nextTrackItemClicked)?:
			return AudioPlayer.shared.hasNextTrack
		case #selector(previousTrackItemClicked)?:
			return AudioPlayer.shared.hasPreviousTrack
		default:
			return true
		}
	}
}

extension AppDelegate {
	func showWelcomeScreenIfNeeded() {
		guard AppMeta.isFirstLaunch else {
			return
		}

		NSAlert.showModal(
			// TODO: Remove `mainWindowController?.window` at some point. It's only for existing users.
			for: loginWindowController?.window ?? mainWindowController?.window,
			message: "Welcome to Plug!",
			informativeText:
				"""
				Plug lets you listen to music from Hype Machine. An internet connection is required.

				If you have any feedback, bug reports, or feature requests, click “Send Feedback” in the “Help” menu. We respond to all submissions.
				""",
			buttonTitles: [
				"Get Started"
			],
			defaultButtonIndex: -1
		)
	}
}
