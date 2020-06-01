import Cocoa

final class PreferencesViewController: NSViewController {
	@IBOutlet private var generalTab: NSButton!
	private var tabViewController: NSTabViewController!

	override func viewDidLoad() {
		super.viewDidLoad()

		Analytics.trackView("PreferencesWindow/General")
	}

	private func toggleAllTabsExcept(_ sender: NSButton) {
		let allTabs = [
			generalTab
		]

		for tab in allTabs {
			tab?.state = tab === sender ? .on : .off
		}
	}

	private func switchToTabAtIndex(_ index: Int) {
		ensureTabViewController()
		tabViewController.selectedTabViewItemIndex = index
	}

	private func ensureTabViewController() {
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
