//
//	SectionHeaderTableCellView.swift
//	Plug
//
//	Created by Alex Marchant on 10/20/14.
//	Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SectionHeaderTableCellView: NSTableCellView {
	var titleTextField: NSTextField!

	override var objectValue: Any! {
		didSet {
			objectValueChanged()
		}
	}

	var sectionHeader: SectionHeader {
		objectValue as! SectionHeader
	}

	func objectValueChanged() {
		guard objectValue != nil else {
			return
		}

		updateTitle()
	}

	func updateTitle() {
		titleTextField!.stringValue = sectionHeader.title
	}
}
