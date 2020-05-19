//
//	RegEx.swift
//	Plug
//
//	Created by Alex Marchant on 8/19/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

class Regex {
	let internalExpression: NSRegularExpression
	let pattern: String

	init(pattern: String) {
		self.pattern = pattern
		self.internalExpression = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
	}

	func test(_ input: String) -> Bool {
		let matches = internalExpression.matches(in: input, options: [], range: NSRange(location: 0, length: input.count))
		return !matches.isEmpty
	}
}

infix operator =~

func =~ (input: String, pattern: String) -> Bool {
	Regex(pattern: pattern).test(input)
}
