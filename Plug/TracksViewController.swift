import Cocoa
import HypeMachineAPI

class TracksViewController: DataSourceViewController {
	let type: TracksViewControllerType
	var tracksDataSource: TracksDataSource? {
		dataSource! as? TracksDataSource
	}

	var previousMouseInsideRow: Int = -1
	var anchoredRow: Int?
	var anchoredCellViewViewController: TracksViewController?

	var showLoveButton: Bool = true

	init?(type: TracksViewControllerType, title: String, analyticsViewName: String) {
		self.type = type
		super.init(title: title, analyticsViewName: analyticsViewName)

		AudioPlayer.shared.onShuffleChanged.addObserver(self) { weakSelf, shuffle in
			if let favoriteTracksDataSource = weakSelf.tracksDataSource as? FavoriteTracksDataSource {
				weakSelf.addLoaderView()
				favoriteTracksDataSource.shuffle = shuffle
				favoriteTracksDataSource.refresh()
			}
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		Notifications.unsubscribeAll(observer: self)
	}

	func loadDataSource() {
		addLoaderView()
		tableView.dataSource = dataSource!
		dataSource!.loadNextPageObjects()
	}

	override func nextPageDidLoad(_ pageNumber: Int) {
		if let favoriteTracksDataSource = tracksDataSource as? FavoriteTracksDataSource, favoriteTracksDataSource.shuffle {
			removeLoaderView()
		} else {
			super.nextPageDidLoad(pageNumber)
		}
	}

	func cellViewForRow(_ row: Int) -> TrackTableCellView? {
		if let cell = tableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? TrackTableCellView {
			cell.dataSource = tracksDataSource
			return cell
		} else {
			return nil
		}
	}

	func distanceFromBottomOfScrollView() -> CGFloat {
		let documentViewHeight = scrollView.documentView!.frame.height
		let bottomPositionOfDocumentVisibleRect = scrollView.documentVisibleRect.origin.y + scrollView.documentVisibleRect.size.height
		return documentViewHeight - bottomPositionOfDocumentVisibleRect
	}

	func heatMapCellView(_ tableView: NSTableView) -> HeatMapTrackTableCellView {
		let id = "HeatMapTrackTableCellViewID"
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? HeatMapTrackTableCellView

		if cellView == nil {
			cellView = HeatMapTrackTableCellView()
			cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)

			setupTrackCellView(cellView!)
			setupHeatMapCellView(cellView!)
		}

		return cellView!
	}

	func loveCountCellView(_ tableView: NSTableView) -> LoveCountTrackTableCellView {
		let id = "LoveCountTrackTableCellViewID"
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? LoveCountTrackTableCellView

		if cellView == nil {
			cellView = LoveCountTrackTableCellView()
			cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)

			setupTrackCellView(cellView!)
			setupLoveCountCellView(cellView!)
		}

		return cellView!
	}

	func feedCellView(_ tableView: NSTableView) -> FeedTrackTableCellView {
		let id = "FeedTrackTableCellViewID"
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? FeedTrackTableCellView

		if cellView == nil {
			cellView = FeedTrackTableCellView()
			cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)

			setupTrackCellView(cellView!)
			setupLoveCountCellView(cellView!)
			setupFeedCellView(cellView!)
		}

		return cellView!
	}

	func setupTrackCellView(_ cellView: TrackTableCellView) {
		cellView.showLoveButton = showLoveButton

		cellView.playPauseButton = HoverToggleButton()
		cellView.playPauseButton.isHidden = true
		cellView.playPauseButton.onImage = NSImage(named: "Track-Pause-Normal")!
		cellView.playPauseButton.onHoverImage = NSImage(named: "Track-Pause-Hover")!
		cellView.playPauseButton.offImage = NSImage(named: "Track-Play-Normal")!
		cellView.playPauseButton.offHoverImage = NSImage(named: "Track-Play-Hover")!
		cellView.playPauseButton.target = cellView
		cellView.playPauseButton.action = #selector(cellView.playPauseButtonClicked)
		cellView.addSubview(cellView.playPauseButton)
		cellView.playPauseButton.snp.makeConstraints { make in
			make.centerY.equalTo(cellView)
			make.size.equalTo(34)
			make.left.equalTo(cellView).offset(19)
		}

		let loveContainer = NSView()
		cellView.addSubview(loveContainer)
		loveContainer.snp.makeConstraints { make in
			cellView.loveContainerWidthConstraint = make.width.equalTo(38).constraint
			make.top.equalTo(cellView)
			make.bottom.equalTo(cellView)
			make.right.equalTo(cellView)
		}

		cellView.loveButton = TransparentButton()
		cellView.loveButton.selectable = true
		cellView.loveButton.selectedImage = NSImage(named: "Track-Loved-On")!
		cellView.loveButton.unselectedImage = NSImage(named: "Track-Loved-Off")!
		cellView.loveButton.target = cellView
		cellView.loveButton.action = #selector(cellView.loveButtonClicked)
		loveContainer.addSubview(cellView.loveButton)
		cellView.loveButton.snp.makeConstraints { make in
			make.centerY.equalTo(loveContainer)
			make.width.equalTo(18)
			make.height.equalTo(18)
			make.left.equalTo(loveContainer)
		}

		cellView.infoContainer = NSView()
		cellView.addSubview(cellView.infoContainer)
		cellView.infoContainer.snp.makeConstraints { make in
			cellView.infoContainerWidthConstraint = make.width.equalTo(30).constraint
			make.top.equalTo(cellView)
			make.bottom.equalTo(cellView)
			make.right.equalTo(loveContainer.snp.left)
		}

		let infoButton = TransparentButton()
		infoButton.unselectedImage = NSImage(named: "Track-Info")!
		infoButton.target = cellView
		infoButton.action = #selector(cellView.infoButtonClicked)
		cellView.infoContainer.addSubview(infoButton)
		infoButton.snp.makeConstraints { make in
			make.centerY.equalTo(cellView.infoContainer)
			make.width.equalTo(18)
			make.height.equalTo(18)
			make.left.equalTo(cellView.infoContainer)
		}

		cellView.titleButton = HyperlinkButton()
		cellView.titleButton.isBordered = false
		cellView.titleButton.lineBreakMode = .byTruncatingTail
		cellView.titleButton.font = appFont(size: 14, weight: .medium)
		cellView.addSubview(cellView.titleButton)
		cellView.titleButton.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(cellView).offset(10)
			make.left.equalTo(cellView).offset(73)
			make.right.lessThanOrEqualTo(cellView.infoContainer.snp.left).offset(-20)
		}

		cellView.artistButton = HyperlinkButton()
		cellView.artistButton.hoverUnderline = true
		cellView.artistButton.isBordered = false
		cellView.artistButton.lineBreakMode = .byTruncatingTail
		cellView.artistButton.font = appFont(size: 13, weight: .medium)
		cellView.artistButton.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
		cellView.artistButton.target = cellView
		cellView.artistButton.action = #selector(cellView.artistButtonClicked)
		cellView.addSubview(cellView.artistButton)
		cellView.artistButton.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(cellView.titleButton.snp.bottom).offset(2)
			make.left.equalTo(cellView).offset(73)
			make.right.lessThanOrEqualTo(cellView.infoContainer.snp.left).offset(-20)
		}

		cellView.progressSlider = FlatSlider()
		let sliderCell = FlatSliderCell()
		sliderCell.barColor = NSColor(red256: 225, green256: 230, blue256: 233)
		sliderCell.barFillColor = NSColor(red256: 255, green256: 95, blue256: 82)
		sliderCell.knobSize = 12
		sliderCell.knobFillColor = NSColor(red256: 255, green256: 95, blue256: 82)
		cellView.progressSlider.cell = sliderCell
		cellView.progressSlider.target = cellView
		cellView.progressSlider.action = #selector(cellView.progressSliderDragged)
		cellView.addSubview(cellView.progressSlider)
		cellView.progressSlider.snp.makeConstraints { make in
			make.left.equalTo(cellView).offset(-8)
			make.bottom.equalTo(cellView).offset(6)
			make.right.equalTo(cellView).offset(14)
		}
	}

	func setupLoveCountCellView(_ cellView: LoveCountTrackTableCellView) {
		cellView.loveCount = ColorChangingTextField()
		cellView.loveCount.isSelectable = false
		cellView.loveCount.isEditable = false
		cellView.loveCount.isBordered = false
		cellView.loveCount.drawsBackground = false
		cellView.loveCount.alignment = .center
		cellView.loveCount.font = appFont(size: 22, weight: .medium)
		cellView.loveCount.objectValue = NSNumber(value: 2200 as Int)
		cellView.loveCount.formatter = LovedCountFormatter()
		cellView.addSubview(cellView.loveCount)
		cellView.loveCount.snp.makeConstraints { make in
			make.centerY.equalTo(cellView)
			make.left.equalTo(cellView)
			make.width.equalTo(72)
			make.height.equalTo(26)
		}
	}

	func setupHeatMapCellView(_ cellView: HeatMapTrackTableCellView) {
		cellView.heatMapView = HeatMapView()
		cellView.addSubview(cellView.heatMapView)
		cellView.heatMapView.snp.makeConstraints { make in
			make.centerY.equalTo(cellView)
			make.width.equalTo(32)
			make.height.equalTo(32)
			make.left.equalTo(cellView).offset(20)
		}
	}

	func setupFeedCellView(_ cellView: FeedTrackTableCellView) {
		cellView.sourceTypeTextField = SelectableTextField()
		cellView.sourceTypeTextField.isEditable = false
		cellView.sourceTypeTextField.isSelectable = false
		cellView.sourceTypeTextField.isBordered = false
		cellView.sourceTypeTextField.drawsBackground = false
		cellView.sourceTypeTextField.font = appFont(size: 12, weight: .medium)
		cellView.sourceTypeTextField.textColor = NSColor(red256: 175, green256: 179, blue256: 181)
		cellView.addSubview(cellView.sourceTypeTextField)
		cellView.sourceTypeTextField.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(cellView.artistButton.snp.bottom).offset(2)
			make.left.equalTo(cellView).offset(74)
		}

		cellView.sourceButton = HyperlinkButton()
		cellView.sourceButton.hoverUnderline = true
		cellView.sourceButton.isBordered = false
		cellView.sourceButton.lineBreakMode = .byTruncatingTail
		cellView.sourceButton.font = appFont(size: 12, weight: .medium)
		cellView.sourceButton.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
		cellView.sourceButton.target = cellView
		cellView.sourceButton.action = #selector(cellView.sourceButtonClicked)
		cellView.addSubview(cellView.sourceButton)
		cellView.sourceButton.snp.makeConstraints { make in
			make.height.equalTo(20)
			make.top.equalTo(cellView.artistButton.snp.bottom).offset(0)
			make.left.equalTo(cellView.sourceTypeTextField.snp.right).offset(1)
			make.right.lessThanOrEqualTo(cellView.infoContainer.snp.left).offset(-20)
		}
	}

	// MARK: Unavailable tracks

	func showHideUnavailableTracks() {
		let hideUnavailableTracks = UserDefaults.standard.value(forKey: HideUnavailableTracks) as! Bool
		dataSource?.filtering = hideUnavailableTracks
	}

	// MARK: NSResponder

	override func keyDown(with theEvent: NSEvent) {
		switch theEvent.keyCode {
		case 36: // Enter
			let row = tableView.selectedRow
			let track = tracksDataSource!.objectForRow(row)! as! HypeMachineAPI.Track
			AudioPlayer.shared.playNewTrack(track, dataSource: tracksDataSource!)
		default:
			super.keyDown(with: theEvent)
		}
	}

	// MARK: NSViewController

	override func loadView() {
		super.loadView()

		loadScrollViewAndTableView()
		scrollView.snp.makeConstraints { make in
			make.edges.equalTo(self.view)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.extendedDelegate = self

		if dataSource != nil {
			loadDataSource()
		}

		showHideUnavailableTracks()

		Notifications.subscribe(observer: self, selector: #selector(BaseContentViewController.refresh), name: Notifications.RefreshCurrentView, object: nil)
		UserDefaults.standard.addObserver(self, forKeyPath: HideUnavailableTracks, options: NSKeyValueObservingOptions.new, context: nil)
	}

	// MARK: BaseContentViewController

	override func refresh() {
		addLoaderView()
		dataSource!.refresh()
	}

	override func isTrackVisible(_ track: HypeMachineAPI.Track) -> Bool {
		for row in tableView.visibleRows {
			let rowTrack = tracksDataSource!.objectForRow(row) as? HypeMachineAPI.Track
			if rowTrack == track &&
				isTableViewRowFullyVisible(row) {
				return true
			}
		}

		return false
	}

	func trackAboveOrBelow(_ track: HypeMachineAPI.Track, tracksDataSource: TracksDataSource) -> StickyTrackPosition {
		if tracksDataSource != self.tracksDataSource {
			return .bottom
		}

		let row = tracksDataSource.indexOfTrack(track)!
		let firstVisibleRow = tableView.visibleRows[0]
		let firstFullyVisibleRow = isTableViewRowFullyVisible(firstVisibleRow) ? firstVisibleRow : firstVisibleRow + 1
		return row < firstFullyVisibleRow ? .top : .bottom
	}

	func isTableViewRowFullyVisible(_ row: Int) -> Bool {
		tableView.isRowFullyVisible(row)
	}

	override var stickyTrackControllerType: TracksViewControllerType {
		switch self.type {
		case .heatMap, .loveCount:
			return .loveCount
		case .feed:
			return .feed
		}
	}

	// MARK: Notifications

	override func newCurrentTrack(_ notification: Notification) {
		super.newCurrentTrack(notification)

		let tracksDataSource = (notification as NSNotification).userInfo!["tracksDataSource"] as! TracksDataSource
		if tracksDataSource == self.tracksDataSource {
			stickyTrackBelongsToUs = true
		} else {
			stickyTrackBelongsToUs = false
		}

		if !stickyTrackBelongsToUs ||
			stickyTrackController.isShown {
			let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
			addStickyTrackAtPosition(trackAboveOrBelow(track, tracksDataSource: tracksDataSource))
		}
	}

	// MARK: DataSourceViewController

	override func dataSourceChanged() {
		if isViewLoaded {
			loadDataSource()
		}
	}

	// MARK: NSTableViewDelegate

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch type {
		case .heatMap:
			return heatMapCellView(tableView)
		case .loveCount:
			return loveCountCellView(tableView)
		case .feed:
			return feedCellView(tableView)
		}
	}

	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		let id = "IOSStyleTableRowViewID"
		var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? IOSStyleTableRowView

		if rowView == nil {
			rowView = IOSStyleTableRowView()
			rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
			rowView!.separatorSpacing = 74
		}

		return rowView!
	}

	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		switch type {
		case .feed:
			return 84
		default:
			return 64
		}
	}

	// MARK: ExtendedTableViewDelegate

	override func tableView(_ tableView: NSTableView, mouseEnteredRow row: Int) {
		if let cellView = cellViewForRow(row) {
			cellView.mouseInside = true
		}
		previousMouseInsideRow = row
	}

	override func tableView(_ tableView: NSTableView, mouseExitedRow row: Int) {
		if let cellView = cellViewForRow(row) {
			cellView.mouseInside = false
		}
	}

	override func tableView(_ tableView: ExtendedTableView, rowDidStartToShow row: Int, direction: RowShowHideDirection) {}

	override func tableView(_ tableView: ExtendedTableView, rowDidStartToHide row: Int, direction: RowShowHideDirection) {
		if let track = tracksDataSource!.objectForRow(row) as? HypeMachineAPI.Track {
			if track == AudioPlayer.shared.currentTrack {
				let position = (direction == .above ? StickyTrackPosition.top : StickyTrackPosition.bottom)
				addStickyTrackAtPosition(position)
			}
		}
	}

	override func tableView(_ tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection) {
		if let track = tracksDataSource!.objectForRow(row) as? HypeMachineAPI.Track {
			if track == AudioPlayer.shared.currentTrack {
				removeStickyTrack()
			}

			if row >= max(0, tableView.numberOfRows - tracksDataSource!.infiniteLoadTrackCountFromEnd) {
				tracksDataSource!.loadNextPageObjects()
			}
		}
	}

	override func tableView(_ tableView: ExtendedTableView, wasDoubleClicked theEvent: NSEvent, atRow row: Int) {
		if let track = tracksDataSource!.objectForRow(row) as? HypeMachineAPI.Track {
			if track != AudioPlayer.shared.currentTrack {
				AudioPlayer.shared.playNewTrack(track, dataSource: tracksDataSource!)
			}
		}
	}

	override func tableView(_ tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection) {}

	override func didEndScrollingTableView(_ tableView: ExtendedTableView) {}

	override func tableView(_ tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int) {
		let track = tracksDataSource!.objectForRow(row) as! HypeMachineAPI.Track
		let menuController = TrackContextMenuController(track: track)!
		NSMenu.popUpContextMenu(menuController.contextMenu, with: theEvent, for: view)
	}

	// MARK: NSKeyValueObserving

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		guard let keyPath = keyPath else {
			return
		}

		if keyPath == HideUnavailableTracks {
			showHideUnavailableTracks()
		}
	}
}

enum TracksViewControllerType {
	case heatMap
	case loveCount
	case feed
}
