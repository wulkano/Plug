//
//	Array+contains.swift
//	Plug
//
//	Created by Alexander Marchant on 7/16/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

extension Array {
	func first() -> Element? {
		!isEmpty ? self[0] : nil
	}

	func last() -> Element? {
		!isEmpty ? self[count - 1] : nil
	}

	func optionalAtIndex(_ index: Int) -> Element? {
		if count > index && index >= 0 {
			return self[index]
		} else {
			return nil
		}
	}
}
