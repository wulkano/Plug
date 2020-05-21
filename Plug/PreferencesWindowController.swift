import Cocoa

final class PreferencesWindowController: NSWindowController {
	var trafficButtons: TrafficButtons!

	override func windowDidLoad() {
		super.windowDidLoad()

		window!.titleVisibility = NSWindow.TitleVisibility.visible

		trafficButtons = TrafficButtons(style: .light, groupIdentifier: "PreferencesWindow")
		trafficButtons.addButtonsToWindow(window!, origin: CGPoint(x: 10, y: 8))
		trafficButtons.zoomButton.isEnabled = false
	}
}
