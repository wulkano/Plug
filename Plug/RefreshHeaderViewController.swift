import Cocoa

final class RefreshHeaderViewController: NSViewController {
	enum PullToRefreshState {
		case pullToRefresh
		case releaseToRefresh
		case updating

		fileprivate var label: String {
			switch self {
			case .pullToRefresh:
				return "Pull To Refresh"
			case .releaseToRefresh:
				return "Release To Refresh"
			case .updating:
				return "Updating Playlist"
			}
		}
	}

	let viewHeight: CGFloat = 30

	var state = PullToRefreshState.pullToRefresh {
		didSet {
			stateChanged()
		}
	}

	var lastUpdated: Date? {
		didSet {
			lastUpdatedChanged()
		}
	}

	private var loader: NSImageView!
	private var messageLabel: NSTextField!

	override func loadView() {
		view = NSView()

		let background = BackgroundBorderView()
		background.bottomBorder = true
		view.addSubview(background)
		background.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}

		let messageContainer = NSView()
		background.addSubview(messageContainer)
		messageContainer.snp.makeConstraints { make in
			make.center.equalTo(background)
		}

		loader = NSImageView()
		loader.image = NSImage(named: "Loader-Refresh")
		messageContainer.addSubview(loader)
		loader.snp.makeConstraints { make in
			make.size.equalTo(16)
			make.top.equalTo(messageContainer)
			make.left.equalTo(messageContainer)
			make.bottom.equalTo(messageContainer)
		}

		messageLabel = NSTextField()
		messageLabel.isEditable = false
		messageLabel.isSelectable = false
		messageLabel.isBordered = false
		messageLabel.drawsBackground = false
		messageLabel.lineBreakMode = .byTruncatingTail
		messageLabel.font = appFont(size: 13, weight: .medium)
		messageLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
		messageContainer.addSubview(messageLabel)
		messageLabel.snp.makeConstraints { make in
			make.centerY.equalTo(messageContainer).offset(-2)
			make.left.equalTo(loader.snp.right).offset(5)
			make.right.equalTo(messageContainer)
		}

		updateMessageLabel()
	}

	private func stateChanged() {
		updateLoader()
		updateMessageLabel()
	}

	private func lastUpdatedChanged() {
		updateMessageLabel()
	}

	private func updateLoader() {
		if state == .updating {
			Animations.rotateClockwise(loader)
		} else {
			Animations.removeAllAnimations(loader)
		}
	}

	private func updateMessageLabel() {
		switch state {
		case .pullToRefresh:
			messageLabel.stringValue = formattedTimestamp
		case .releaseToRefresh:
			messageLabel.stringValue = state.label
		case .updating:
			messageLabel.stringValue = state.label
		}
	}

	private var formattedTimestamp: String {
		var formattedTimestamp = "Last Updated "

		if lastUpdated == nil {
			formattedTimestamp += "N/A"
		} else {
			let formatter = DateFormatter()
			formatter.dateFormat = "h:mm a"
			formattedTimestamp += formatter.string(from: lastUpdated!)
		}

		return formattedTimestamp
	}
}
