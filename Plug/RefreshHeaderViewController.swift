import Cocoa

final class RefreshHeaderViewController: NSViewController {
	enum PullToRefreshState {
		case pullToRefresh
		case releaseToRefresh
		case updating

		fileprivate var label: String {
			switch self {
			case .pullToRefresh:
				"Pull To Refresh"
			case .releaseToRefresh:
				"Release To Refresh"
			case .updating:
				"Updating Playlist"
			}
		}
	}

	let viewHeight = 30.0

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

	private lazy var progressIndicator: NSProgressIndicator = {
		let progressIndicator = NSProgressIndicator()
		progressIndicator.style = .spinning
		progressIndicator.isIndeterminate = true
		progressIndicator.controlSize = .small
		return progressIndicator
	}()

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

		messageContainer.addSubview(progressIndicator)
		progressIndicator.snp.makeConstraints { make in
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
		messageLabel.textColor = .secondaryLabelColor
		messageContainer.addSubview(messageLabel)
		messageLabel.snp.makeConstraints { make in
			make.centerY.equalTo(messageContainer)
			make.left.equalTo(progressIndicator.snp.right).offset(8)
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
			progressIndicator.startAnimation(self)
		} else {
			progressIndicator.stopAnimation(self)
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
