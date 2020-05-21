import Cocoa

final class PreferencesViewController: NSViewController {
	@IBOutlet private var generalTab: NSButton!
	var tabViewController: NSTabViewController!

	override func viewDidLoad() {
		super.viewDidLoad()

		Analytics.trackView("PreferencesWindow/General")
	}

	func toggleAllTabsExcept(_ sender: NSButton) {
		let allTabs = [
			generalTab
		]

		for tab in allTabs {
			if tab === sender {
				tab?.state = .on
			} else {
				tab?.state = .off
			}
		}
	}

	func switchToTabAtIndex(_ index: Int) {
		ensureTabViewController()
		tabViewController.selectedTabViewItemIndex = index
	}

	func ensureTabViewController() {
		guard tabViewController == nil else {
			return
		}

		for controller in children where controller is NSTabViewController {
			tabViewController = controller as? NSTabViewController
		}
	}

	// MARK: Actions

	@IBAction private func generalTabClicked(_ sender: NSButton) {
		Analytics.trackView("PreferencesWindow/General")
		toggleAllTabsExcept(sender)
		switchToTabAtIndex(0)
	}
}
