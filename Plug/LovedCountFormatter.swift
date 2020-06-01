import Cocoa

final class LovedCountFormatter: Formatter {
	@IBInspectable var shouldCapitalize = false

	override func string(for object: Any?) -> String? {
		let count = (object as! NSNumber).intValue
		var returnString: String?

		if count >= 1000 {
			let numberFormatter = NumberFormatter()
			numberFormatter.format = "####k"
			let abbrLovedCount = Double(count) / 1000
			returnString = numberFormatter.string(from: NSNumber(value: abbrLovedCount))
		} else {
			returnString = "\(count)"
		}

		if shouldCapitalize {
			returnString = returnString!.uppercased()
		}

		return returnString
	}
}
