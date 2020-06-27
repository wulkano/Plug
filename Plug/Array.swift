import Foundation

extension Array {
	var last: Element? { !isEmpty ? self[count - 1] : nil }

	func optionalAtIndex(_ index: Int) -> Element? {
		guard count > index, index >= 0 else {
			return nil
		}

		return self[index]
	}
}
