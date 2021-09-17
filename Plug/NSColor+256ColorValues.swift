import Cocoa

extension NSColor {
	convenience init(red256 red: Int, green256 green: Int, blue256 blue: Int) {
		self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: 1)
	}

	convenience init(red256 red: Int, green256 green: Int, blue256 blue: Int, alpha: Double) {
		self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, alpha: alpha)
	}
}
