import Cocoa

final class RefreshClipView: NSClipView {
	private var refreshScrollView: RefreshScrollView { superview as! RefreshScrollView }

	private var refreshHeaderController: RefreshHeaderViewController {
		refreshScrollView.refreshHeaderController
	}

	override var documentRect: CGRect {
		var newRect = super.documentRect

		// If refreshing, expand the rect to fit the refresh header
		// in the frame (without scroll elaticity).
		if refreshHeaderController.state == .updating {
			newRect.size.height += refreshHeaderController.viewHeight
			newRect.origin.y -= refreshHeaderController.viewHeight
		}

		return newRect
	}
}
