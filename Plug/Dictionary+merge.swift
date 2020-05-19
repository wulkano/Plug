//
//	Dictionary+merge.swift
//	Plug
//
//	Created by Alex Marchant on 6/3/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

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
