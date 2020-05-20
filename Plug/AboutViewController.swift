//
//	AboutViewController.swift
//	Plug
//
//	Created by Alex Marchant on 7/14/15.
//	Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
	func label(_ container: NSView) -> NSTextField {
		let textField = NSTextField()
		textField.isEditable = false
		textField.isSelectable = false
		textField.isBordered = false
		textField.drawsBackground = false
		textField.alignment = .center

		container.addSubview(textField)
		textField.snp.makeConstraints { make in
			make.left.equalTo(container).offset(5)
			make.right.equalTo(container).offset(-5)
		}

		return textField
	}

	func attributionSectionTitled(_ title: String, name: String, linkTitle: String, linkAction: Selector) -> NSView {
		let container = NSView()
		view.addSubview(container)
		container.snp.makeConstraints { make in
			make.left.equalTo(view)
			make.right.equalTo(view)
		}

		let titleLabel = label(container)
		titleLabel.font = appFont(size: 12, weight: .bold)
		titleLabel.stringValue = title
		titleLabel.snp.makeConstraints { make in
			make.top.equalTo(container)
		}

		let nameLabel = label(container)
		nameLabel.font = appFont(size: 12)
		nameLabel.stringValue = name
		nameLabel.snp.makeConstraints { make in
			make.top.equalTo(titleLabel.snp.bottom).offset(-3)
		}

		let link = HyperlinkButton()
		link.hoverUnderline = true
		link.isBordered = false
		link.font = appFont(size: 12)
		link.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
		link.alignment = .center
		link.title = linkTitle
		link.target = self
		link.action = linkAction
		container.addSubview(link)
		link.snp.makeConstraints { make in
			make.height.equalTo(17)
			make.centerX.equalTo(container)
			make.top.equalTo(nameLabel.snp.bottom).offset(-2)
			make.bottom.equalTo(container)
		}

		return container
	}

	// MARK: Actions

	@objc func glennLinkClicked(_ sender: NSButton) {
		NSWorkspace.shared.open(URL(string: "http://www.twitter.com/glennui")!)
	}

	@objc func alexLinkClicked(_ sender: NSButton) {
		NSWorkspace.shared.open(URL(string: "http://www.twitter.com/alex_marchant")!)
	}

	// MARK: NSViewController

	override func loadView() {
		view = NSView()
		view.snp.makeConstraints { make in
			make.width.equalTo(285)
		}

		let logo = NSImageView()
		logo.image = NSImage(named: "Login-Logo")
		view.addSubview(logo)
		logo.snp.makeConstraints { make in
			make.centerX.equalTo(view)
			make.size.equalTo(64)
			make.top.equalTo(view).offset(12)
		}

		let nameLabel = label(view)
		nameLabel.font = appFont(size: 14, weight: .bold)
		nameLabel.stringValue = "Plug"
		nameLabel.snp.makeConstraints { make in
			make.top.equalTo(logo.snp.bottom).offset(20)
		}

		let versionLabel = label(view)
		versionLabel.font = appFont(size: 11)
		let bundleVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
		let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
		versionLabel.stringValue = "Version \(bundleVersionString) (\(bundleVersion))"
		versionLabel.snp.makeConstraints { make in
			make.top.equalTo(nameLabel.snp.bottom).offset(3)
		}

		let glennSection = attributionSectionTitled("Design", name: "Glenn Hitchcock", linkTitle: "@glennui", linkAction: #selector(AboutViewController.glennLinkClicked(_:)))
		glennSection.snp.makeConstraints { make in
			make.top.equalTo(versionLabel.snp.bottom).offset(16)
		}

		let alexSection = attributionSectionTitled("Development", name: "Alex Marchant", linkTitle: "@alex_marchant", linkAction: #selector(AboutViewController.alexLinkClicked(_:)))
		alexSection.snp.makeConstraints { make in
			make.top.equalTo(glennSection.snp.bottom).offset(2)
		}

		let copyright = label(view)
		copyright.font = appFont(size: 11)
		copyright.stringValue = App.copyright
		copyright.snp.makeConstraints { make in
			make.top.equalTo(alexSection.snp.bottom).offset(10)
			make.bottom.equalTo(view).offset(-17)
		}
	}
}
