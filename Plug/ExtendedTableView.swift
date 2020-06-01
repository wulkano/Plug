import Cocoa

class ExtendedTableView: NSTableView, RefreshScrollViewBoundsChangedDelegate {
	@IBInspectable var isTrackingMouseEnterExit = false
	@IBInspectable var hasPullToRefresh = false

	var isScrollEnabled = true

	var isScrolling = false
	var isScrollingTimer: Interval?

	var trackingArea: NSTrackingArea?

	var extendedDelegate: ExtendedTableViewDelegate?
	var mouseInsideRow = -1

	var clipView: NSClipView { superview as! NSClipView }

	var previousVisibleRect = CGRect.zero
	var scrollView: NSScrollView? { clipView.superview as? NSScrollView }

	var visibleRows: [Int] {
		let trueVisibleRect = insetRect(visibleRect, insets: contentInsets)
		let rowRange = rows(in: trueVisibleRect).toRange()!
		return Array(rowRange.lowerBound..<rowRange.upperBound)
	}

	var previousVisibleRows: [Int] = []
	var previousRowDidStartToHide = -1
	var previousRowDidStartToShow = -1
	var previousRowDidHide = -1
	var previousRowDidShow = -1
	var previousScrollDirection = ScrollDirection.up

	deinit {
		Notifications.unsubscribeAll(observer: self)
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()

		updateContentInsets()
		updateScrollerInsets()
		updateTrackingAreas()
	}

	override func viewDidMoveToSuperview() {
		super.viewDidMoveToSuperview()

		if let refreshScrollView = scrollView as? RefreshScrollView {
			refreshScrollView.boundsChangedDelegate = self
		}
	}

	override func updateTrackingAreas() {
		super.updateTrackingAreas()

		if let trackingArea = self.trackingArea {
			removeTrackingArea(trackingArea)
			self.trackingArea = nil
		}

		let options: NSTrackingArea.Options = [.activeAlways, .mouseEnteredAndExited, .mouseMoved, .assumeInside]
		let trackingRect = insetRect(clipView.documentVisibleRect, insets: scrollerInsets)
		trackingArea = NSTrackingArea(rect: trackingRect, options: options, owner: self, userInfo: nil)
		addTrackingArea(trackingArea!)
	}

	func insetRect(_ rect: CGRect, insets: NSEdgeInsets) -> CGRect {
		guard rect != .zero else {
			return rect
		}

		var newRect = rect

		newRect.origin.x += insets.left
		newRect.origin.y += insets.top
		newRect.size.width -= insets.left
		newRect.size.width -= insets.right
		newRect.size.height -= insets.top
		newRect.size.height -= insets.bottom

		return newRect
	}

	override func mouseDown(with theEvent: NSEvent) {
		let clickedRow = rowForEvent(theEvent)

		super.mouseDown(with: theEvent)

		if theEvent.clickCount == 2 {
			extendedDelegate?.tableView(self, wasDoubleClicked: theEvent, atRow: clickedRow)
			return
		}

		guard clickedRow != -1 else {
			return
		}

		extendedDelegate?.tableView(self, wasClicked: theEvent, atRow: clickedRow)
	}

	override func rightMouseDown(with theEvent: NSEvent) {
		let clickedRow = rowForEvent(theEvent)

		guard clickedRow != -1 else {
			return
		}

		extendedDelegate?.tableView(self, wasRightClicked: theEvent, atRow: clickedRow)
	}

	override func mouseMoved(with theEvent: NSEvent) {
		super.mouseMoved(with: theEvent)

		let newMouseInsideRow = rowForEvent(theEvent)

		if newMouseInsideRow != mouseInsideRow {
			if newMouseInsideRow != -1 {
				extendedDelegate?.tableView(self, mouseEnteredRow: newMouseInsideRow)
			}

			if mouseInsideRow != -1 {
				extendedDelegate?.tableView(self, mouseExitedRow: mouseInsideRow)
			}

			mouseInsideRow = newMouseInsideRow
		}
	}

	func rowForEvent(_ theEvent: NSEvent) -> Int {
		let globalLocation = theEvent.locationInWindow
		let localLocation = convert(globalLocation, from: nil)
		return row(at: localLocation)
	}

	override func mouseEntered(with theEvent: NSEvent) {
		super.mouseEntered(with: theEvent)
	}

	override func mouseExited(with theEvent: NSEvent) {
		super.mouseExited(with: theEvent)

		if mouseInsideRow != -1 {
			extendedDelegate?.tableView(self, mouseExitedRow: mouseInsideRow)
			mouseInsideRow = -1
		}
	}

	func isRowFullyVisible(_ row: Int) -> Bool {
		let trueVisibleRect = insetRect(visibleRect, insets: contentInsets)
		let rowRect = rect(ofRow: row)

		return trueVisibleRect.contains(rowRect)
	}

	func scrollViewBoundsDidChange(_ notification: Notification) {
		if !isScrolling {
			isScrolling = true
			scrollViewDidStartScrolling(notification)
		} else {
			scrollViewDidScroll(notification)
			startTimerForEndScrolling()
		}
	}

	func startTimerForEndScrolling() {
		isScrollingTimer?.invalidate()
		isScrollingTimer = Interval.single(0.1) {
			self.isScrolling = false
			self.scrollViewDidEndScrolling(Notification(name: Notification.Name("nil"), object: self))
		}
	}

	func scrollViewDidStartScrolling(_ notification: Notification) {
		if mouseInsideRow != -1 {
			extendedDelegate?.tableView(self, mouseExitedRow: mouseInsideRow)
			mouseInsideRow = -1
		}
	}

	func scrollViewDidScroll(_ notification: Notification) {
		let direction = scrollDirection()

		updateRowDidStartToShow(direction)
		updateRowDidStartToHide(direction)
		updateRowDidShow(direction)
		updateRowDidHide(direction)

		extendedDelegate?.didScrollTableView(self)

		previousVisibleRect = visibleRect
		previousVisibleRows = visibleRows

		previousScrollDirection = direction
	}


	func scrollViewDidEndScrolling(_ notification: Notification) {
		extendedDelegate?.didEndScrollingTableView(self)
	}

	func scrollDirection() -> ScrollDirection {
		if visibleRect.origin.y >= previousVisibleRect.origin.y {
			return .down
		} else {
			return .up
		}
	}

	// TODO: NOT DRY, PLZ FIX
	// If you're looking at this in > 1 month, you're an idiot
	// and you knew you'd just procrastinate fixing this
	// shitty code. But at least you were self-aware enough
	// to know, that's something right?

	func updateRowDidStartToShow(_ scrollDirection: ScrollDirection) {
		let point: CGPoint
		let shownDirection: RowShowHideDirection

		switch scrollDirection {
		case .up:
			var topPoint = visibleRect.origin
			topPoint.y += contentInsets.top
			point = topPoint
			shownDirection = .above
		case .down:
			var bottomPoint = visibleRect.origin
			bottomPoint.y += clipView.frame.size.height
			bottomPoint.y -= contentInsets.bottom
			point = bottomPoint
			shownDirection = .below
		}

		let row = self.row(at: point)
		if row != previousRowDidStartToShow {
			if scrollDirection == previousScrollDirection &&
				row != -1 &&
				previousRowDidStartToHide != -1 {
				for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidStartToShow) {
					extendedDelegate?.tableView(self, rowDidStartToShow: eachRow, direction: shownDirection)
				}
			} else {
				extendedDelegate?.tableView(self, rowDidStartToShow: row, direction: shownDirection)
			}

			previousRowDidStartToShow = row
		}
	}

	func updateRowDidStartToHide(_ scrollDirection: ScrollDirection) {
		let point: CGPoint
		let hiddenDirection: RowShowHideDirection

		switch scrollDirection {
		case .up:
			var bottomPoint = visibleRect.origin
			bottomPoint.y += clipView.frame.size.height
			bottomPoint.y -= contentInsets.bottom
			bottomPoint.y += 1
			point = bottomPoint
			hiddenDirection = .below
		case .down:
			var topPoint = visibleRect.origin
			topPoint.y += contentInsets.top
			topPoint.y -= 1
			point = topPoint
			hiddenDirection = .above
		}

		let row = self.row(at: point)
		if row != previousRowDidStartToHide {
			if scrollDirection == previousScrollDirection &&
				row != -1 &&
				previousRowDidStartToHide != -1 {
				for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidStartToHide) {
					extendedDelegate?.tableView(self, rowDidStartToHide: eachRow, direction: hiddenDirection)
				}
			} else {
				extendedDelegate?.tableView(self, rowDidStartToHide: row, direction: hiddenDirection)
			}

			previousRowDidStartToHide = row
		}
	}

	func updateRowDidShow(_ scrollDirection: ScrollDirection) {
		let point: CGPoint
		let shownDirection: RowShowHideDirection

		let rowHeight: CGFloat = delegate!.tableView!(self, heightOfRow: 0)

		switch scrollDirection {
		case .up:
			var topPoint = visibleRect.origin
			topPoint.y += rowHeight
			topPoint.y += contentInsets.top
			topPoint.y -= 1
			point = topPoint
			shownDirection = .above
		case .down:
			var bottomPoint = visibleRect.origin
			bottomPoint.y += clipView.frame.size.height
			bottomPoint.y -= rowHeight
			bottomPoint.y -= contentInsets.bottom
			bottomPoint.y += 1
			point = bottomPoint
			shownDirection = .below
		}

		let row = self.row(at: point)
		if row != previousRowDidShow {
			if scrollDirection == previousScrollDirection &&
				row != -1 &&
				previousRowDidShow != -1 {
				for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidShow) {
					extendedDelegate?.tableView(self, rowDidShow: eachRow, direction: shownDirection)
				}
			} else {
				extendedDelegate?.tableView(self, rowDidShow: row, direction: shownDirection)
			}

			previousRowDidShow = row
		}
	}

	func updateRowDidHide(_ scrollDirection: ScrollDirection) {
		let point: CGPoint
		let hiddenDirection: RowShowHideDirection

		let rowHeight: CGFloat = delegate!.tableView!(self, heightOfRow: 0)

		switch scrollDirection {
		case .up:
			var bottomPoint = visibleRect.origin
			bottomPoint.y += clipView.frame.size.height
			bottomPoint.y += rowHeight
			bottomPoint.y -= contentInsets.bottom
			bottomPoint.y += 1
			point = bottomPoint
			hiddenDirection = .below
		case .down:
			var topPoint = visibleRect.origin
			topPoint.y -= rowHeight
			topPoint.y += contentInsets.top
			topPoint.y -= 1
			point = topPoint
			hiddenDirection = .above
		}

		let row = self.row(at: point)
		if row != previousRowDidHide {
			if scrollDirection == previousScrollDirection &&
				row != -1 &&
				previousRowDidHide != -1 {
				for eachRow in rangeBetweenCurrentRow(row, andPreviousRow: previousRowDidHide) {
					extendedDelegate?.tableView(self, rowDidHide: eachRow, direction: hiddenDirection)
				}
			} else {
				extendedDelegate?.tableView(self, rowDidHide: row, direction: hiddenDirection)
			}

			previousRowDidHide = row
		}
	}

	// When you scroll fast sometimes we don't detect all rows being scrolled over
	// so this makes sure to catch any skipped rows
	func rangeBetweenCurrentRow(_ currentRow: Int, andPreviousRow previousRow: Int) -> CountableRange<Int> {
		if currentRow > previousRow {
			return CountableRange(uncheckedBounds: (lower: previousRow + 1, upper: currentRow + 1))
		} else {
			return CountableRange(uncheckedBounds: (lower: currentRow, upper: previousRow))
		}
	}

	func newVisibleRows() -> [Int] {
		let rows = visibleRows.filter { !self.previousVisibleRows.contains($0) }
		return rows
	}

	func newHiddenRows() -> [Int] {
		let rows = previousVisibleRows.filter { !self.visibleRows.contains($0) }
		return rows
	}

	func average(_ array: [Int]) -> Double {
		Double(array.reduce(0) { $0 + $1 }) / Double(array.count)
	}

	// MARK: insets

	var contentInsets: NSEdgeInsets = NSEdgeInsetsZero {
		didSet {
			updateContentInsets()
		}
	}

	var scrollerInsets: NSEdgeInsets = NSEdgeInsetsZero {
		didSet {
			updateScrollerInsets()
		}
	}

	func updateContentInsets() {
		clipView.automaticallyAdjustsContentInsets = false
		clipView.contentInsets = contentInsets
	}

	func updateScrollerInsets() {
		scrollView!.scrollerInsets = scrollerInsets
		updateTrackingAreas()
	}
}

// TODO: Swift 2.0 update with default implementation to make these optional

protocol ExtendedTableViewDelegate {
	func tableView(_ tableView: ExtendedTableView, wasClicked theEvent: NSEvent, atRow row: Int)
	func tableView(_ tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int)
	func tableView(_ tableView: ExtendedTableView, wasDoubleClicked theEvent: NSEvent, atRow row: Int)
	func tableView(_ tableView: ExtendedTableView, mouseEnteredRow row: Int)
	func tableView(_ tableView: ExtendedTableView, mouseExitedRow row: Int)
	func tableView(_ tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection)
	func tableView(_ tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection)
	func tableView(_ tableView: ExtendedTableView, rowDidStartToShow row: Int, direction: RowShowHideDirection)
	func tableView(_ tableView: ExtendedTableView, rowDidStartToHide row: Int, direction: RowShowHideDirection)
	func didEndScrollingTableView(_ tableView: ExtendedTableView)
	func didScrollTableView(_ tableView: ExtendedTableView)
}

enum RowShowHideDirection: Int {
	case above
	case below
}

enum ScrollDirection {
	case down
	case up
}
