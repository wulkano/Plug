//
//  TracksViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class TracksViewController: DataSourceViewController {
    let type: TracksViewControllerType
    var tracksDataSource: TracksDataSource? {
        return dataSource! as? TracksDataSource
    }
    
    var previousMouseInsideRow: Int = -1
    var anchoredRow: Int?
    var anchoredCellViewViewController: TracksViewController?
    
    let infiniteScrollCellCountFromLastTriggerCount: Int = 7
    
    var showLoveButton: Bool = true
    
    init?(type: TracksViewControllerType, title: String, analyticsViewName: String) {
        self.type = type
        super.init(title: title, analyticsViewName: analyticsViewName)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Notifications.unsubscribeAll(observer: self)
    }
    
    func loadDataSource() {
        addLoaderView()
        tableView.setDataSource(dataSource!)
        dataSource!.loadNextPageObjects()
    }
    
    func cellViewForRow(row: Int) -> TrackTableCellView? {
        if let cell = tableView.viewAtColumn(0, row: row, makeIfNecessary: false) as? TrackTableCellView {
            cell.dataSource = tracksDataSource
            return cell
        } else {
            return nil
        }
    }
    
    func distanceFromBottomOfScrollView() -> CGFloat {
        let documentViewHeight = (scrollView.documentView as! NSView).frame.height
        let bottomPositionOfDocumentVisibleRect = scrollView.documentVisibleRect.origin.y + scrollView.documentVisibleRect.size.height
        return documentViewHeight - bottomPositionOfDocumentVisibleRect
    }
    
    func heatMapCellView(tableView: NSTableView) -> HeatMapTrackTableCellView {
        let id = "HeatMapTrackTableCellViewID"
        var cellView = tableView.makeViewWithIdentifier(id, owner: self) as? HeatMapTrackTableCellView
        
        if cellView == nil {
            cellView = HeatMapTrackTableCellView()
            cellView!.identifier = id
            
            setupTrackCellView(cellView!)
            setupHeatMapCellView(cellView!)
        }
        
        return cellView!
    }
    
    func loveCountCellView(tableView: NSTableView) -> LoveCountTrackTableCellView {
        let id = "LoveCountTrackTableCellViewID"
        var cellView = tableView.makeViewWithIdentifier(id, owner: self) as? LoveCountTrackTableCellView
        
        if cellView == nil {
            cellView = LoveCountTrackTableCellView()
            cellView!.identifier = id
            
            setupTrackCellView(cellView!)
            setupLoveCountCellView(cellView!)
        }
        
        return cellView!
    }
    
    func feedCellView(tableView: NSTableView) -> FeedTrackTableCellView {
        let id = "FeedTrackTableCellViewID"
        var cellView = tableView.makeViewWithIdentifier(id, owner: self) as? FeedTrackTableCellView
        
        if cellView == nil {
            cellView = FeedTrackTableCellView()
            cellView!.identifier = id
            
            setupTrackCellView(cellView!)
            setupLoveCountCellView(cellView!)
            setupFeedCellView(cellView!)
        }
        
        return cellView!
    }
    
    func setupTrackCellView(cellView: TrackTableCellView) {
        cellView.showLoveButton = showLoveButton
        
        cellView.playPauseButton = HoverToggleButton()
        cellView.playPauseButton.hidden = true
        cellView.playPauseButton.onImage = NSImage(named: "Track-Pause-Normal")!
        cellView.playPauseButton.onHoverImage = NSImage(named: "Track-Pause-Hover")!
        cellView.playPauseButton.offImage = NSImage(named: "Track-Play-Normal")!
        cellView.playPauseButton.offHoverImage = NSImage(named: "Track-Play-Hover")!
        cellView.playPauseButton.target = cellView
        cellView.playPauseButton.action = #selector(cellView.playPauseButtonClicked)
        cellView.addSubview(cellView.playPauseButton)
        cellView.playPauseButton.snp_makeConstraints { make in
            make.centerY.equalTo(cellView)
            make.size.equalTo(34)
            make.left.equalTo(cellView).offset(19)
        }
        
        let loveContainer = NSView()
        cellView.addSubview(loveContainer)
        loveContainer.snp_makeConstraints { make in
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
        cellView.loveButton.snp_makeConstraints { make in
            make.centerY.equalTo(loveContainer)
            make.width.equalTo(18)
            make.height.equalTo(18)
            make.left.equalTo(loveContainer)
        }
        
        cellView.infoContainer = NSView()
        cellView.addSubview(cellView.infoContainer)
        cellView.infoContainer.snp_makeConstraints { make in
            cellView.infoContainerWidthConstraint = make.width.equalTo(30).constraint
            make.top.equalTo(cellView)
            make.bottom.equalTo(cellView)
            make.right.equalTo(loveContainer.snp_left)
        }
        
        let infoButton = TransparentButton()
        infoButton.unselectedImage = NSImage(named: "Track-Info")!
        infoButton.target = cellView
        infoButton.action = #selector(cellView.infoButtonClicked)
        cellView.infoContainer.addSubview(infoButton)
        infoButton.snp_makeConstraints { make in
            make.centerY.equalTo(cellView.infoContainer)
            make.width.equalTo(18)
            make.height.equalTo(18)
            make.left.equalTo(cellView.infoContainer)
        }
        
        cellView.titleButton = HyperlinkButton()
        cellView.titleButton.bordered = false
        cellView.titleButton.lineBreakMode = .ByTruncatingTail
        cellView.titleButton.font = appFont(size: 14, weight: .Medium)
        cellView.addSubview(cellView.titleButton)
        cellView.titleButton.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(cellView).offset(10)
            make.left.equalTo(cellView).offset(73)
            make.right.lessThanOrEqualTo(cellView.infoContainer.snp_left).offset(-20)
        }
        
        cellView.artistButton = HyperlinkButton()
        cellView.artistButton.hoverUnderline = true
        cellView.artistButton.bordered = false
        cellView.artistButton.lineBreakMode = .ByTruncatingTail
        cellView.artistButton.font = appFont(size: 13, weight: .Medium)
        cellView.artistButton.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        cellView.artistButton.target = cellView
        cellView.artistButton.action = #selector(cellView.artistButtonClicked)
        cellView.addSubview(cellView.artistButton)
        cellView.artistButton.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(cellView.titleButton.snp_bottom).offset(2)
            make.left.equalTo(cellView).offset(73)
            make.right.lessThanOrEqualTo(cellView.infoContainer.snp_left).offset(-20)
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
        cellView.progressSlider.snp_makeConstraints { make in
            make.left.equalTo(cellView).offset(-8)
            make.bottom.equalTo(cellView).offset(6)
            make.right.equalTo(cellView).offset(14)
        }
    }
    
    func setupLoveCountCellView(cellView: LoveCountTrackTableCellView) {
        cellView.loveCount = ColorChangingTextField()
        cellView.loveCount.selectable = false
        cellView.loveCount.editable = false
        cellView.loveCount.bordered = false
        cellView.loveCount.drawsBackground = false
        cellView.loveCount.alignment = .Center
        cellView.loveCount.font = appFont(size: 22, weight: .Medium)
        cellView.loveCount.objectValue = NSNumber(integer: 2200)
        cellView.loveCount.formatter = LovedCountFormatter()
        cellView.addSubview(cellView.loveCount)
        cellView.loveCount.snp_makeConstraints { make in
            make.centerY.equalTo(cellView)
            make.left.equalTo(cellView)
            make.width.equalTo(72)
            make.height.equalTo(26)
        }
    }
    
    func setupHeatMapCellView(cellView: HeatMapTrackTableCellView) {
        cellView.heatMapView = HeatMapView()
        cellView.addSubview(cellView.heatMapView)
        cellView.heatMapView.snp_makeConstraints { make in
            make.centerY.equalTo(cellView)
            make.width.equalTo(32)
            make.height.equalTo(32)
            make.left.equalTo(cellView).offset(20)
        }
    }
    
    func setupFeedCellView(cellView: FeedTrackTableCellView) {
        cellView.sourceTypeTextField = SelectableTextField()
        cellView.sourceTypeTextField.editable = false
        cellView.sourceTypeTextField.selectable = false
        cellView.sourceTypeTextField.bordered = false
        cellView.sourceTypeTextField.drawsBackground = false
        cellView.sourceTypeTextField.font = appFont(size: 12, weight: .Medium)
        cellView.sourceTypeTextField.textColor = NSColor(red256: 175, green256: 179, blue256: 181)
        cellView.addSubview(cellView.sourceTypeTextField)
        cellView.sourceTypeTextField.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(cellView.artistButton.snp_bottom).offset(2)
            make.left.equalTo(cellView).offset(74)
        }
        
        cellView.sourceButton = HyperlinkButton()
        cellView.sourceButton.hoverUnderline = true
        cellView.sourceButton.bordered = false
        cellView.sourceButton.lineBreakMode = .ByTruncatingTail
        cellView.sourceButton.font = appFont(size: 12, weight: .Medium)
        cellView.sourceButton.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        cellView.sourceButton.target = cellView
        cellView.sourceButton.action = #selector(cellView.sourceButtonClicked)
        cellView.addSubview(cellView.sourceButton)
        cellView.sourceButton.snp_makeConstraints { make in
            make.height.equalTo(20)
            make.top.equalTo(cellView.artistButton.snp_bottom).offset(0)
            make.left.equalTo(cellView.sourceTypeTextField.snp_right).offset(1)
            make.right.lessThanOrEqualTo(cellView.infoContainer.snp_left).offset(-20)
        }
    }
    
    // MARK: Unavailable tracks
    
    func showHideUnavailableTracks() {
        let hideUnavailableTracks = NSUserDefaults.standardUserDefaults().valueForKey(HideUnavailableTracks) as! Bool
        dataSource?.filtering = hideUnavailableTracks
    }
    
    // MARK: NSResponder
    
    override func keyDown(theEvent: NSEvent) {
        switch theEvent.keyCode {
        case 36: // Enter
            let row = tableView.selectedRow
            let track = tracksDataSource!.objectForRow(row)! as! HypeMachineAPI.Track
            AudioPlayer.sharedInstance.playNewTrack(track, dataSource: tracksDataSource!)
        default:
            super.keyDown(theEvent)
        }
    }
    
    // MARK: NSViewController
    
    override func loadView() {
        super.loadView()
        
        loadScrollViewAndTableView()
        scrollView.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.setDelegate(self)
        tableView.extendedDelegate = self
        
        if dataSource != nil {
            loadDataSource()
        }
        
        showHideUnavailableTracks()
        
        Notifications.subscribe(observer: self, selector: #selector(BaseContentViewController.refresh), name: Notifications.RefreshCurrentView, object: nil)
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: HideUnavailableTracks, options: NSKeyValueObservingOptions.New, context: nil)
    }
    
    // MARK: BaseContentViewController
    
    override func refresh() {
        addLoaderView()
        dataSource!.refresh()
    }
    
    override func isTrackVisible(track: HypeMachineAPI.Track) -> Bool {
        for row in tableView.visibleRows {
            let rowTrack = tracksDataSource!.objectForRow(row) as? HypeMachineAPI.Track
            if (rowTrack == track &&
                isTableViewRowFullyVisible(row)) {
                return true
            }
        }
        
        return false
    }
    
    func trackAboveOrBelow(track: HypeMachineAPI.Track, tracksDataSource: TracksDataSource) -> StickyTrackPosition {
        if tracksDataSource != self.tracksDataSource {
            return .Bottom
        }
        
        let row = tracksDataSource.indexOfTrack(track)
        let firstVisibleRow = tableView.visibleRows[0] ?? 0
        let firstFullyVisibleRow = isTableViewRowFullyVisible(firstVisibleRow) ? firstVisibleRow : firstVisibleRow+1
        return row < firstFullyVisibleRow ? .Top : .Bottom
    }
    
    func isTableViewRowFullyVisible(row: Int) -> Bool {
        return tableView.isRowFullyVisible(row)
    }
    
    override var stickyTrackControllerType: TracksViewControllerType {
        switch self.type {
        case .HeatMap, .LoveCount:
            return .LoveCount
        case .Feed:
            return .Feed
        }
    }
    
    // MARK: Notifications
    
    override func newCurrentTrack(notification: NSNotification) {
        super.newCurrentTrack(notification)
        
        let tracksDataSource = notification.userInfo!["tracksDataSource"] as! TracksDataSource
        if tracksDataSource == self.tracksDataSource {
            stickyTrackBelongsToUs = true
        } else {
            stickyTrackBelongsToUs = false
        }
        
        if (!stickyTrackBelongsToUs ||
            stickyTrackController.isShown) {
            let track = notification.userInfo!["track"] as! HypeMachineAPI.Track
            addStickyTrackAtPosition(trackAboveOrBelow(track, tracksDataSource: tracksDataSource))
        }
    }
    
    // MARK: DataSourceViewController
    
    override func dataSourceChanged() {
        if viewLoaded {
            loadDataSource()
        }
    }
    
    // MARK: NSTableViewDelegate
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        switch type {
        case .HeatMap:
            return heatMapCellView(tableView)
        case .LoveCount:
            return loveCountCellView(tableView)
        case .Feed:
            return feedCellView(tableView)
        }
    }
    
    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let id = "IOSStyleTableRowViewID"
        var rowView = tableView.makeViewWithIdentifier(id, owner: self) as? IOSStyleTableRowView
        
        if rowView == nil {
            rowView = IOSStyleTableRowView()
            rowView!.identifier = id
            rowView!.separatorSpacing = 74
        }
        
        return rowView!
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        switch type {
        case .Feed:
            return 84
        default:
            return 64
        }
    }
    
    // MARK: ExtendedTableViewDelegate
    
    override func tableView(tableView: NSTableView, mouseEnteredRow row: Int) {
        if let cellView = cellViewForRow(row) {
            cellView.mouseInside = true
        }
        previousMouseInsideRow = row
    }
    
    override func tableView(tableView: NSTableView, mouseExitedRow row: Int) {
        if let cellView = cellViewForRow(row) {
            cellView.mouseInside = false
        }
    }
    
    override func tableView(tableView: ExtendedTableView, rowDidStartToShow row: Int, direction: RowShowHideDirection) {}
    
    override func tableView(tableView: ExtendedTableView, rowDidStartToHide row: Int, direction: RowShowHideDirection) {
        if let track = tracksDataSource!.objectForRow(row) as? HypeMachineAPI.Track {
            if track === AudioPlayer.sharedInstance.currentTrack {
                let position = (direction == .Above ? StickyTrackPosition.Top : StickyTrackPosition.Bottom)
                addStickyTrackAtPosition(position)
            }
        }
    }
    
    override func tableView(tableView: ExtendedTableView, rowDidShow row: Int, direction: RowShowHideDirection) {
        if let track = tracksDataSource!.objectForRow(row) as? HypeMachineAPI.Track {
            if track === AudioPlayer.sharedInstance.currentTrack {
                removeStickyTrack()
            }
            
            if row >= max(0, tableView.numberOfRows-infiniteScrollCellCountFromLastTriggerCount) {
                tracksDataSource!.loadNextPageObjects()
            }
        }
    }
    
    override func tableView(tableView: ExtendedTableView, rowDidHide row: Int, direction: RowShowHideDirection) {}
    
    override func didEndScrollingTableView(tableView: ExtendedTableView) {}
    
    override func tableView(tableView: ExtendedTableView, wasRightClicked theEvent: NSEvent, atRow row: Int) {
        let track = tracksDataSource!.objectForRow(row) as! HypeMachineAPI.Track
        let menuController = TrackContextMenuController(track: track)!
        NSMenu.popUpContextMenu(menuController.contextMenu, withEvent: theEvent, forView: view)
    }
    
    // MARK: NSKeyValueObserving
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let keyPath = keyPath else { return }
        if keyPath == HideUnavailableTracks {
            showHideUnavailableTracks()
        }
    }
}

enum TracksViewControllerType {
    case HeatMap
    case LoveCount
    case Feed
}