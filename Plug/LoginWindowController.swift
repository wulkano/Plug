import Cocoa

final class LoginWindowController: NSWindowController {
	var trafficButtons: TrafficButtons!

	override func windowDidLoad() {
		super.windowDidLoad()

		trafficButtons = TrafficButtons(style: .dark, groupIdentifier: "LoginWindow")
		trafficButtons.addButtonsToWindow(window!, origin: CGPoint(x: 20, y: 20))
		trafficButtons.zoomButton.isEnabled = false
	}
}
