import Cocoa

final class SearchHeaderViewController: NSViewController {
	var searchField: NSSearchField!

	override func loadView() {
		view = NSView()

		let background = BackgroundBorderView()
		background.hasBackground = true
		background.backgroundColor = .white
		background.bottomBorder = true
		background.borderColor = NSColor(red256: 225, green256: 230, blue256: 233)
		view.addSubview(background)
		background.snp.makeConstraints { make in
			make.edges.equalTo(view)
		}

		searchField = NSSearchField()
		searchField.sendsWholeSearchString = true
		background.addSubview(searchField)
		searchField.snp.makeConstraints { make in
			make.centerY.equalTo(view)
			make.left.equalTo(view).offset(10)
			make.right.equalTo(view).offset(-10)
		}
	}
}
