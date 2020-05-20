//
//	FriendsViewController.swift
//	Plug
//
//	Created by Alex Marchant on 8/1/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class UsersViewController: DataSourceViewController {
	var usersDataSource: UsersDataSource? {
		dataSource! as? UsersDataSource
	}

	func loadSingleFriendView(_ friend: HypeMachineAPI.User) {
		let viewController = UserViewController(user: friend)!
		NavigationController.sharedInstance!.pushViewController(viewController, animated: true)
	}

	// MARK: Actions

	@objc func searchFieldSubmit(_ sender: NSSearchField) {
		usersDataSource!.searchKeywords = sender.stringValue
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
		searchHeaderController.searchField.action = #selector(UsersViewController.searchFieldSubmit(_:))

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

		dataSource = UsersDataSource(viewController: self)
		tableView.dataSource = dataSource
		dataSource!.loadNextPageObjects()
	}

	override func refresh() {
		addLoaderView()
		dataSource!.refresh()
	}

	// MARK: NSTableViewDelegate

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let id = "UserTableCellViewID"
		var cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? UserTableCellView

		if cellView == nil {
			cellView = UserTableCellView()
			cellView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)

			cellView!.avatarView = CircleMaskImageView()
			cellView!.avatarView.image = NSImage(named: "Avatar-Placeholder")!
			cellView!.addSubview(cellView!.avatarView)
			cellView!.avatarView.snp.makeConstraints { make in
				make.centerY.equalTo(cellView!)
				make.width.equalTo(36)
				make.height.equalTo(36)
				make.left.equalTo(cellView!).offset(17)
			}

			cellView!.fullNameTextField = NSTextField()
			cellView!.fullNameTextField.isEditable = false
			cellView!.fullNameTextField.isSelectable = false
			cellView!.fullNameTextField.isBordered = false
			cellView!.fullNameTextField.drawsBackground = false
			cellView!.fullNameTextField.font = appFont(size: 14, weight: .medium)
			cellView!.addSubview(cellView!.fullNameTextField)
			cellView!.fullNameTextField.snp.makeConstraints { make in
				make.left.equalTo(cellView!.avatarView.snp.right).offset(22)
				make.top.equalTo(cellView!).offset(12)
				make.right.equalTo(cellView!).offset(27)
			}

			cellView!.usernameTextField = NSTextField()
			cellView!.usernameTextField.isEditable = false
			cellView!.usernameTextField.isSelectable = false
			cellView!.usernameTextField.isBordered = false
			cellView!.usernameTextField.drawsBackground = false
			cellView!.usernameTextField.font = appFont(size: 13, weight: .medium)
			cellView!.usernameTextField.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
			cellView!.addSubview(cellView!.usernameTextField)
			cellView!.usernameTextField.snp.makeConstraints { make in
				make.left.equalTo(cellView!.avatarView.snp.right).offset(22)
				make.top.equalTo(cellView!.fullNameTextField.snp.bottom).offset(4)
				make.right.equalTo(cellView!).offset(27)
			}

			let arrow = NSImageView()
			arrow.image = NSImage(named: "List-Arrow")!
			cellView!.addSubview(arrow)
			arrow.snp.makeConstraints { make in
				make.centerY.equalTo(cellView!)
				make.right.equalTo(cellView!).offset(-15)
			}
		}

		return cellView
	}

	func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
		let id = "IOSStyleTableRowViewID"
		var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: self) as? IOSStyleTableRowView

		if rowView == nil {
			rowView = IOSStyleTableRowView()
			rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
			rowView!.separatorSpacing = 73
		}

		return rowView
	}

	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		64
	}

	// MARK: ExtendedTableViewDelegate

	override func tableView(_ tableView: NSTableView, wasClicked theEvent: NSEvent, atRow row: Int) {
		if let item: Any = dataSource!.objectForRow(row) {
			loadSingleFriendView(item as! HypeMachineAPI.User)
		}
	}
}
