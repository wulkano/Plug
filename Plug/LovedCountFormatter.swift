//
//	LoveCountFormatter.swift
//	Plug
//
//	Created by Alex Marchant on 8/28/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LovedCountFormatter: Formatter {
	@IBInspectable var capitalize: Bool = false

	override func string(for obj: Any?) -> String? {
		let count = (obj as! NSNumber).intValue
		var returnString: String?

		if count >= 1000 {
			let numberFormatter = NumberFormatter()
			numberFormatter.format = "####k"
			let abbrLovedCount = Double(count) / 1000
			returnString = numberFormatter.string(from: NSNumber(value: abbrLovedCount))
		} else {
			returnString = "\(count)"
		}

		if capitalize {
			returnString = returnString!.uppercased()
		}

		return returnString
	}
}
