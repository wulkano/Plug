import Cocoa
import HypeMachineAPI
import SnapKit

// swiftlint:disable:next final_class
class BaseContentViewController: NSViewController {
	let analyticsViewName: String
	var loaderViewController: LoaderViewController?
	var navigationItem: NavigationItem!

	var tableViewInsets: NSEdgeInsets {
		NSEdgeInsets(top: 0, left: 0, bottom: 47, right: 0) // Play controls
	}

	init?(title: String, analyticsViewName: String) {
		self.analyticsViewName = analyticsViewName
		super.init(nibName: nil, bundle: nil)

		self.title = title
		self.navigationItem = NavigationItem(title: title)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		Notifications.unsubscribeAll(observer: self)
	}

	override func loadView() {
		view = NSView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		addLoaderView()

		if shouldShowStickyTrack {
			setupStickyTrack()
		}

		subscribeToNotifications()
	}

	func addLoaderView() {
		if loaderViewController == nil {
			loaderViewController = LoaderViewController(size: .large)
			let insets = NSEdgeInsets(top: 0, left: 0, bottom: 47, right: 0)
			view.addSubview(loaderViewController!.view)
			loaderViewController!.view.snp.makeConstraints { make in
				make.edges.equalTo(view).inset(insets)
			}
		}
	}

	func removeLoaderView() {
		if loaderViewController != nil {
			loaderViewController!.view.removeFromSuperview()
			loaderViewController = nil
		}
	}

	@objc
	func refresh() { // swiftlint:disable:this unavailable_function
		fatalError("refresh() not implemented")
	}

	func subscribeToNotifications() {
		if shouldShowStickyTrack {
			Notifications.subscribe(observer: self, selector: #selector(BaseContentViewController.newCurrentTrack(_:)), name: Notifications.NewCurrentTrack, object: nil)
		}
	}

	// MARK: Sticky Track

	var shouldShowStickyTrack: Bool { true }

	var stickyTrackControllerStore: StickyTrackViewController?
	var stickyTrackController: StickyTrackViewController {
		if stickyTrackControllerStore == nil {
			stickyTrackControllerStore = StickyTrackViewController(type: stickyTrackControllerType, title: "", analyticsViewName: "Sticky")
		}

		return stickyTrackControllerStore!
	}

	var stickyTrackControllerType: TracksViewControllerType { .loveCount }

	var stickyTrackBelongsToUs = false

	func setupStickyTrack() {
		if let currentTrack = AudioPlayer.shared.currentTrack {
			addStickyTrackAtPosition(.bottom)
			updateStickyTrack(currentTrack)
		}
	}

	func addStickyTrackAtPosition(_ position: StickyTrackPosition) {
		if stickyTrackController.isShown {
			if position == stickyTrackController.position {
				return
			} else {
				stickyTrackController.view.removeFromSuperview()
			}
		}

		view.addSubview(stickyTrackController.view)
		switch position {
		case .top:
			stickyTrackController.view.snp.makeConstraints { make in
				make.height.equalTo(stickyTrackController.viewHeight)
				make.left.right.equalTo(view)
				make.top.equalTo(view).offset(tableViewInsets.top)
			}
		case .bottom:
			stickyTrackController.view.snp.makeConstraints { make in
				make.height.equalTo(stickyTrackController.viewHeight)
				make.left.right.equalTo(view)
				make.bottom.equalTo(view).offset(-tableViewInsets.bottom)
			}
		}

		stickyTrackController.position = position
	}

	func removeStickyTrack() {
		stickyTrackController.view.removeFromSuperview()
	}

	func updateStickyTrack(_ track: HypeMachineAPI.Track) {
		stickyTrackController.dataSource = SingleTrackDataSource(viewController: stickyTrackController, track: track)
	}

	func isTrackVisible(_ track: HypeMachineAPI.Track) -> Bool { false }

	// MARK: Notifications

	@objc
	func newCurrentTrack(_ notification: Notification) {
		let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
		updateStickyTrack(track)

		if isTrackVisible(track) {
			removeStickyTrack()
		} else {
			addStickyTrackAtPosition(.bottom)
		}
	}
}

enum StickyTrackPosition: Int {
	case top
	case bottom
}
