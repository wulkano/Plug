import Cocoa
import HypeMachineAPI

final class TagsViewController: DataSourceViewController {
	var tagsDataSource: TagsDataSource? { dataSource as? TagsDataSource }

	func itemForRow(_ row: Int) -> TagsListItem? {
		if let item: Any = dataSource!.objectForRow(row) {
			return TagsListItem.fromObject(item)
		} else {
			return nil
		}
	}

	func itemAfterRow(_ row: Int) -> TagsListItem? {
		if let item: Any = dataSource!.objectForRow(row) {
			return TagsListItem.fromObject(item)
		} else {
			return nil
		}
	}

	func selectedTag() -> HypeMachineAPI.Tag? {
		let row = tableView.selectedRow
		if let item = itemForRow(row) {
			switch item {
			case let .tagItem(tag):
				return tag
			default:
				return nil
			}
		} else {
			return nil
		}
	}

	func enterKeyPressed(_ theEvent: NSEvent) {
		if let tag = selectedTag() {
			loadSingleTagView(tag)
		} else {
			super.keyDown(with: theEvent)
		}
	}

	func rightArrowKeyPressed(_ theEvent: NSEvent) {
		if let tag = selectedTag() {
			loadSingleTagView(tag)
		} else {
			super.keyDown(with: theEvent)
		}
	}

	func loadSingleTagView(_ tag: HypeMachineAPI.Tag) {
		let viewController = TracksViewController(type: .loveCount, title: tag.name, analyticsViewName: "Tag/Tracks")!
		NavigationController.shared!.pushViewController(viewController, animated: true)
		viewController.dataSource = TagTracksDataSource(viewController: viewController, tagName: tag.name)
	}

	func tagCellView(_ tableView: NSTableView) -> TagTableCellView {
		let id = "TagTableCellViewID"
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? TagTableCellView

		if cellView == nil {
			cellView = TagTableCellView()
			cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)

			cellView!.nameTextField = NSTextField()
			cellView!.nameTextField.isEditable = false
			cellView!.nameTextField.isSelectable = false
			cellView!.nameTextField.isBordered = false
			cellView!.nameTextField.drawsBackground = false
			cellView!.nameTextField.font = appFont(size: 16, weight: .medium)
			cellView!.addSubview(cellView!.nameTextField)
			cellView!.nameTextField.snp.makeConstraints { make in
				make.centerY.equalTo(cellView!).offset(1)
				make.left.equalTo(cellView!).offset(21)
				make.right.lessThanOrEqualTo(cellView!).offset(-53)
			}

			let arrow = NSImageView()
			arrow.image = NSImage(named: "List-Arrow")!
			cellView!.addSubview(arrow)
			arrow.snp.makeConstraints { make in
				make.centerY.equalTo(cellView!)
				make.right.equalTo(cellView!).offset(-15)
			}
		}

		return cellView!
	}

	func tagRowView(_ tableView: NSTableView, row: Int) -> IOSStyleTableRowView {
		let id = "IOSStyleTableRowViewID"
		var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? IOSStyleTableRowView

		if rowView == nil {
			rowView = IOSStyleTableRowView()
			rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
			rowView!.separatorSpacing = 21

			if let nextItem = itemAfterRow(row) {
				switch nextItem {
				case .sectionHeaderItem:
					rowView!.isNextRowGroupRow = true
				case .tagItem:
					rowView!.isNextRowGroupRow = false
				}
			} else {
				rowView!.isNextRowGroupRow = false
			}
		}

		return rowView!
	}

	// MARK: Actions

	@objc
	func searchFieldSubmit(_ sender: NSSearchField) {
		tagsDataSource!.searchKeywords = sender.stringValue
	}

	// MARK: NSResponder

	override func keyDown(with theEvent: NSEvent) {
		switch theEvent.keyCode {
		case 36:
			enterKeyPressed(theEvent)
		case 124:
			rightArrowKeyPressed(theEvent)
		default:
			super.keyDown(with: theEvent)
		}
	}

	// MARK: NSViewController

	override func loadView() {
		super.loadView()

		let searchHeaderController = SearchHeaderViewController(nibName: nil, bundle: nil)
		view.addSubview(searchHeaderController.view)
		searchHeaderController.view.snp.makeConstraints { make in
			make.height.equalTo(52)
			make.top.equalTo(self.view)
			make.left.equalTo(self.view)
			make.right.equalTo(self.view)
		}
		searchHeaderController.searchField.target = self
		searchHeaderController.searchField.action = #selector(TagsViewController.searchFieldSubmit(_:))

		loadScrollViewAndTableView()
		scrollView.snp.makeConstraints { make in
			make.top.equalTo(searchHeaderController.view.snp.bottom)
			make.left.equalTo(self.view)
			make.bottom.equalTo(self.view)
			make.right.equalTo(self.view)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.extendedDelegate = self

		dataSource = TagsDataSource(viewController: self)
		tableView.dataSource = dataSource
		dataSource?.loadNextPageObjects()
	}

	override func refresh() {
		addLoaderView()
		dataSource!.refresh()
	}

	// MARK: NSTableViewDelegate

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch itemForRow(row)! {
		case .sectionHeaderItem:
			return sectionHeaderCellView(tableView)
		case .tagItem:
			return tagCellView(tableView)
		}
	}

	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		switch itemForRow(row)! {
		case .sectionHeaderItem:
			return groupRowView(tableView)
		case .tagItem:
			return tagRowView(tableView, row: row)
		}
	}

	func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
		switch itemForRow(row)! {
		case .sectionHeaderItem:
			return true
		case .tagItem:
			return false
		}
	}

	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		switch itemForRow(row)! {
		case .sectionHeaderItem:
			return 32
		case .tagItem:
			return 48
		}
	}

	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		switch itemForRow(row)! {
		case .sectionHeaderItem:
			return false
		case .tagItem:
			return true
		}
	}

	// MARK: ExtendedTableViewDelegate

	override func tableView(_ tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
		switch itemForRow(row)! {
		case let .tagItem(tag):
			loadSingleTagView(tag)
		case .sectionHeaderItem:
			return
		}
	}
}
