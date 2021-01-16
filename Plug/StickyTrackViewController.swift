import Cocoa
import HypeMachineAPI

final class StickyTrackViewController: TracksViewController {
	var trackViewHeight: CGFloat { tableView(tableView, heightOfRow: 0) }

	let shadowHeight: CGFloat = 7
	let shadowOverlap: CGFloat = 1
	var viewHeight: CGFloat { trackViewHeight + shadowHeight - shadowOverlap }

	var shadowView: NSImageView?
	var position: StickyTrackPosition = .bottom {
		didSet {
			positionChanged()
		}
	}

	var isShown: Bool { view.superview != nil }

	override var tableViewInsets: NSEdgeInsets { NSEdgeInsetsZero }

	func positionChanged() {
		switch position {
		case .top:
			addShadowToBottom()
		case .bottom:
			addShadowToTop()
		}
	}

	override func rightMouseDown(with theEvent: NSEvent) {
		let menuController = TrackContextMenuController(track: AudioPlayer.shared.currentTrack!)!
		NSMenu.popUpContextMenu(menuController.contextMenu, with: theEvent, for: view)
	}

	func addShadowToBottom() {
		shadowView?.removeFromSuperview()

		scrollView.snp.remakeConstraints { make in
			let insets = NSEdgeInsets(top: 0, left: 0, bottom: shadowHeight - shadowOverlap, right: 0)
			make.edges.equalTo(view).inset(insets)
		}

		shadowView = NSImageView()
		shadowView!.imageScaling = NSImageScaling.scaleAxesIndependently
		shadowView!.image = NSImage(named: "Sticky Track Shadow Bottom")
		view.addSubview(shadowView!)
		shadowView!.snp.makeConstraints { make in
			make.height.equalTo(shadowHeight)
			make.left.equalTo(view)
			make.bottom.equalTo(view)
			make.right.equalTo(view)
		}
	}

	func addShadowToTop() {
		shadowView?.removeFromSuperview()

		scrollView.snp.remakeConstraints { make in
			let insets = NSEdgeInsets(top: shadowHeight - shadowOverlap, left: 0, bottom: 0, right: 0)
			make.edges.equalTo(view).inset(insets)
		}

		shadowView = NSImageView()
		shadowView!.imageScaling = NSImageScaling.scaleAxesIndependently
		shadowView!.image = NSImage(named: "Sticky Track Shadow Top")
		view.addSubview(shadowView!)
		shadowView!.snp.makeConstraints { make in
			make.height.equalTo(shadowHeight)
			make.left.equalTo(view)
			make.top.equalTo(view)
			make.right.equalTo(view)
		}
	}

	// MARK: DataSourceViewController

	override func loadScrollViewAndTableView() {
		super.loadScrollViewAndTableView()

		scrollView.isScrollEnabled = false
	}

	// MARK: BaseContentViewController

	override func addLoaderView() {}

	override var shouldShowStickyTrack: Bool { false }

	override var stickyTrackController: StickyTrackViewController {
		assertionFailure("Should not be loading this from here")
		return StickyTrackViewController(type: .feed, title: "", analyticsViewName: "")!
	}
}
