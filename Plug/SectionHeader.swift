import Cocoa

final class SectionHeader: NSObject {
	var title: String

	init(title: String) {
		self.title = title
		super.init()
	}
}
