import Foundation

extension Dictionary {
	func merge(_ dictionary: [Key: Value]?) -> Dictionary {
		guard let dictionary = dictionary else {
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
