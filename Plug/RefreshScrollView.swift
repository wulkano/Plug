import Cocoa

final class RefreshScrollView: NSScrollView {
	let delegate: RefreshScrollViewDelegate
	var boundsChangedDelegate: RefreshScrollViewBoundsChangedDelegate?

	var isScrolling = false

	var refreshHeaderController: RefreshHeaderViewController!
	var refreshClipView: RefreshClipView { contentView as! RefreshClipView }

	override var contentView: NSClipView {
		willSet {
			contentViewWillChange()
		}
		didSet {
			contentViewChanged()
		}
	}

	var isScrollEnabled = true

	init(delegate: RefreshScrollViewDelegate) {
		self.delegate = delegate
		super.init(frame: .zero)
		setup()
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setup() {
		contentView = RefreshClipView()
	}

	override func viewDidMoveToSuperview() {
		loadRefreshView()
	}

	func loadRefreshView() {
		refreshHeaderController = RefreshHeaderViewController(nibName: nil, bundle: nil)
		refreshClipView.addSubview(refreshHeaderController.view)
		refreshHeaderController.view.snp.makeConstraints { make in
			make.height.equalTo(refreshHeaderController.viewHeight)
			make.left.right.equalTo(refreshClipView)
			make.bottom.equalTo(refreshClipView.snp.top)
		}
	}

	override func scrollWheel(with theEvent: NSEvent) {
		guard isScrollEnabled else {
			return
		}

		switch theEvent.phase {
		case .changed:
			if scrolledPastTopOfRefreshHeader() {
				refreshHeaderController.state = .releaseToRefresh
			} else {
				refreshHeaderController.state = .pullToRefresh
			}
		case .ended:
			if refreshHeaderController.state == .releaseToRefresh {
				startRefresh()
			}
		default:
			break
		}

		super.scrollWheel(with: theEvent)
	}

	func scrolledPastTopOfRefreshHeader() -> Bool {
		refreshClipView.bounds.origin.y <= -refreshHeaderController.viewHeight
	}

	func scrolledPastTopOfContentView() -> Bool {
		contentView.bounds.origin.y < 0
	}

	func startRefresh() {
		refreshHeaderController.state = .updating
		delegate.didPullToRefresh()
	}

	func finishedRefresh() {
		documentView!.scroll(.zero)

		refreshHeaderController.state = .pullToRefresh
		refreshHeaderController.lastUpdated = Date()
	}

	func contentViewWillChange() {
		Notifications.unsubscribe(observer: self, name: NSView.boundsDidChangeNotification, object: contentView)
	}

	func contentViewChanged() {
		contentView.postsFrameChangedNotifications = true
		Notifications.subscribe(observer: self, selector: #selector(contentViewBoundsDidChange), name: NSView.boundsDidChangeNotification, object: contentView)
	}

	@objc
	func contentViewBoundsDidChange(_ notification: Notification) {
		boundsChangedDelegate?.scrollViewBoundsDidChange(notification)
	}
}

protocol RefreshScrollViewDelegate {
	func didPullToRefresh()
}

protocol RefreshScrollViewBoundsChangedDelegate {
	func scrollViewBoundsDidChange(_ notification: Notification)
}
