import Cocoa
import HypeMachineAPI

final class BlogsViewController: DataSourceViewController {
	var blogDataSource: BlogsDataSource? { dataSource as? BlogsDataSource }

	func itemForRow(_ row: Int) -> BlogDirectoryItem? {
		guard let item = dataSource?.objectForRow(row) else {
			return nil
		}

		return BlogDirectoryItem.fromObject(item)
	}

	func itemAfterRow(_ row: Int) -> BlogDirectoryItem? {
		guard let item = dataSource?.objectAfterRow(row) else {
			return nil
		}

		return BlogDirectoryItem.fromObject(item)
	}

	func loadBlogViewController(_ blog: HypeMachineAPI.Blog) {
		let viewController = BlogViewController(blog: blog)
		NavigationController.shared!.pushViewController(viewController, animated: true)
	}

	func blogCellView(_ tableView: NSTableView) -> BlogTableCellView {
		let id = "BlogTableCellViewID"
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? BlogTableCellView

		if cellView == nil {
			cellView = BlogTableCellView()
			cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)

			cellView!.nameTextField = NSTextField()
			cellView!.nameTextField.isEditable = false
			cellView!.nameTextField.isSelectable = false
			cellView!.nameTextField.isBordered = false
			cellView!.nameTextField.drawsBackground = false
			cellView!.nameTextField.font = appFont(size: 14, weight: .medium)
			cellView!.addSubview(cellView!.nameTextField)
			cellView!.nameTextField.snp.makeConstraints { make in
				make.top.equalTo(cellView!).offset(10)
				make.left.equalTo(cellView!).offset(21)
				make.right.lessThanOrEqualTo(cellView!).offset(-53)
			}

			let recentTopOffset = 2.0

			let recentTitle = NSTextField()
			recentTitle.stringValue = "Recent: "
			recentTitle.isEditable = false
			recentTitle.isSelectable = false
			recentTitle.isBordered = false
			recentTitle.drawsBackground = false
			recentTitle.font = appFont(size: 13, weight: .medium)
			recentTitle.textColor = NSColor(red256: 175, green256: 179, blue256: 181)
			cellView!.addSubview(recentTitle)
			recentTitle.snp.makeConstraints { make in
				make.top.equalTo(cellView!.nameTextField.snp.bottom).offset(recentTopOffset)
				make.left.equalTo(cellView!).offset(21)
			}

			cellView!.recentArtistsTextField = NSTextField()
			cellView!.recentArtistsTextField.isEditable = false
			cellView!.recentArtistsTextField.isSelectable = false
			cellView!.recentArtistsTextField.isBordered = false
			cellView!.recentArtistsTextField.drawsBackground = false
			cellView!.recentArtistsTextField.lineBreakMode = .byTruncatingTail
			cellView!.recentArtistsTextField.font = appFont(size: 13, weight: .medium)
			cellView!.recentArtistsTextField.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
			cellView!.addSubview(cellView!.recentArtistsTextField)
			cellView!.recentArtistsTextField.snp.makeConstraints { make in
				make.top.equalTo(cellView!.nameTextField.snp.bottom).offset(recentTopOffset)
				make.left.equalTo(recentTitle.snp.right).offset(1)
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

	func blogRowView(_ tableView: NSTableView, row: Int) -> IOSStyleTableRowView {
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
				case .blogItem:
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
		blogDataSource!.searchKeywords = sender.stringValue
	}

	// MARK: NSViewController

	override func loadView() {
		super.loadView()

		let searchHeaderController = SearchHeaderViewController(nibName: nil, bundle: nil)
		view.addSubview(searchHeaderController.view)
		searchHeaderController.view.snp.makeConstraints { make in
			make.height.equalTo(52)
			make.top.equalTo(view)
			make.left.equalTo(view)
			make.right.equalTo(view)
		}
		searchHeaderController.searchField.target = self
		searchHeaderController.searchField.action = #selector(searchFieldSubmit(_:))

		loadScrollViewAndTableView()
		scrollView.snp.makeConstraints { make in
			make.top.equalTo(searchHeaderController.view.snp.bottom)
			make.left.equalTo(view)
			make.bottom.equalTo(view)
			make.right.equalTo(view)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.delegate = self
		tableView.extendedDelegate = self

		dataSource = BlogsDataSource(viewController: self)
		tableView.dataSource = dataSource
		dataSource!.loadNextPageObjects()
	}

	override func refresh() {
		addLoaderView()
		dataSource!.refresh()
	}

	// MARK: NSTableViewDelegate

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		switch itemForRow(row) {
		case .sectionHeaderItem:
			return sectionHeaderCellView(tableView)
		case .blogItem:
			return blogCellView(tableView)
		default:
			return nil
		}
	}

	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		switch itemForRow(row) {
		case .sectionHeaderItem:
			return groupRowView(tableView)
		case .blogItem:
			return blogRowView(tableView, row: row)
		default:
			return nil
		}
	}

	func tableView(_ tableView: NSTableView, isGroupRow row: Int) -> Bool {
		switch itemForRow(row) {
		case .sectionHeaderItem:
			return true
		case .blogItem:
			return false
		default:
			return false
		}
	}

	// swiftlint:disable:next no_cgfloat
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		switch itemForRow(row) {
		case .sectionHeaderItem:
			return 32
		case .blogItem:
			return 64
		default:
			return 0
		}
	}

	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		switch itemForRow(row) {
		case .sectionHeaderItem:
			return false
		case .blogItem:
			return true
		default:
			return false
		}
	}

	// MARK: ExtendedTableViewDelegate

	override func tableView(_ tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
		switch itemForRow(row) {
		case .blogItem(let blog):
			loadBlogViewController(blog)
		case .sectionHeaderItem:
			return
		default:
			return
		}
	}
}
