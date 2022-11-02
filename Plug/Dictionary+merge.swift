import Foundation

extension Dictionary {
	// swiftlint:disable:next discouraged_optional_collection
	func merge(_ dictionary: [Key: Value]?) -> Dictionary {
		guard let dictionary else {
			return self
		}

		var newDictionary = self
		for key in dictionary.keys {
			if newDictionary[key] != nil {
				continue
			}

			newDictionary[key] = dictionary[key]
		}

		return newDictionary
	}
}
