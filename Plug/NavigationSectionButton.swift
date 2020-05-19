//
//	NavigationSectionButton.swift
//	Plug
//
//	Created by Alex Marchant on 7/5/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class NavigationSectionButton: SwissArmyButton {
	let navigationSection: NavigationSection

	init(navigationSection: NavigationSection) {
		self.navigationSection = navigationSection
		super.init(frame: NSRect.zero)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func setup() {
		super.setup()

		tracksHover = true
		image = NSImage(named: "Nav-\(navigationSection.title)-Off")
		alternateImage = NSImage(named: "Nav-\(navigationSection.title)-On")
	}

	override func setupCell() {
		let cell = TransparentButtonCell(textCell: "")
		cell.allowsSelectedState = true
		self.cell = cell
	}
}
