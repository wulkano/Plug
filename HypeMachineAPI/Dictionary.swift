import Foundation

extension Dictionary { /* <KeyType, ValueType> */
	func merge(_ dictionary: [Key: Value]?) -> Dictionary {
		if dictionary == nil { return self }

		var newDictionary = self
		for key in dictionary!.keys {
			if newDictionary[key] != nil { continue }
			newDictionary[key] = dictionary![key]
		}

		return newDictionary
	}
}
