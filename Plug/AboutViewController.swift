//
//  AboutViewController.swift
//  Plug
//
//  Created by Alex Marchant on 7/14/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    
    func label(container: NSView) -> NSTextField {
        let textField = NSTextField()
        textField.editable = false
        textField.selectable = false
        textField.bordered = false
        textField.drawsBackground = false
        textField.alignment = .Center
        
        container.addSubview(textField)
        textField.snp_makeConstraints { make in
            make.left.equalTo(container).offset(5)
            make.right.equalTo(container).offset(-5)
        }
        
        return textField
    }
    
    func attributionSectionTitled(title: String, name: String, linkTitle: String, linkAction: Selector) -> NSView {
        let container = NSView()
        view.addSubview(container)
        container.snp_makeConstraints { make in
            make.left.equalTo(view)
            make.right.equalTo(view)
        }
        
        let titleLabel = label(container)
        titleLabel.font = NSFont(name: "HelveticaNeue-Bold", size: 12)
        titleLabel.stringValue = title
        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(container)
        }
        
        let nameLabel = label(container)
        nameLabel.font = NSFont(name: "HelveticaNeue", size: 12)
        nameLabel.stringValue = name
        nameLabel.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(-3)
        }
        
        let link = HyperlinkButton()
        link.hoverUnderline = true
        link.bordered = false
        link.font = NSFont(name: "HelveticaNeue", size: 12)!
        link.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        link.alignment = .Center
        link.title = linkTitle
        link.target = self
        link.action = linkAction
        container.addSubview(link)
        link.snp_makeConstraints { make in
            make.height.equalTo(17)
            make.centerX.equalTo(container)
            make.top.equalTo(nameLabel.snp_bottom).offset(-2)
            make.bottom.equalTo(container)
        }
        
        return container
    }
    
    // MARK: Actions
    
    func glennLinkClicked(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://www.twitter.com/glennui")!)
    }

    func alexLinkClicked(sender: NSButton) {
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://www.twitter.com/alex_marchant")!)
    }

    // MARK: NSViewController

    override func loadView() {
        view = NSView()
        view.snp_makeConstraints { make in
            make.width.equalTo(285)
        }
        
        let logo = NSImageView()
        logo.image = NSImage(named: "Login-Logo")
        view.addSubview(logo)
        logo.snp_makeConstraints { make in
            make.centerX.equalTo(view)
            make.size.equalTo(64)
            make.top.equalTo(view).offset(12)
        }
        
        let nameLabel = label(view)
        nameLabel.font = NSFont(name: "HelveticaNeue-Bold", size: 14)
        nameLabel.stringValue = "Plug"
        nameLabel.snp_makeConstraints { make in
            make.top.equalTo(logo.snp_bottom).offset(20)
        }
        
        let versionLabel = label(view)
        versionLabel.font = NSFont(name: "HelveticaNeue", size: 11)
        let bundleVersionString = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let bundleVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
        versionLabel.stringValue = "Version \(bundleVersionString) (\(bundleVersion))"
        versionLabel.snp_makeConstraints { make in
            make.top.equalTo(nameLabel.snp_bottom).offset(3)
        }
        
        let glennSection = attributionSectionTitled("Design", name: "Glenn Hitchcock", linkTitle: "@glennui", linkAction: "glennLinkClicked:")
        glennSection.snp_makeConstraints { make in
            make.top.equalTo(versionLabel.snp_bottom).offset(16)
        }
        
        let alexSection = attributionSectionTitled("Development", name: "Alex Marchant", linkTitle: "@alex_marchant", linkAction: "alexLinkClicked:")
        alexSection.snp_makeConstraints { make in
            make.top.equalTo(glennSection.snp_bottom).offset(2)
        }
        
        let copyright = label(view)
        copyright.font = NSFont(name: "HelveticaNeue", size: 11)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy"
        let year = formatter.stringFromDate(NSDate())
        copyright.stringValue = "Copyright © \(year) Alex Marchant & Glenn Hitchcock."
        copyright.snp_makeConstraints { make in
            make.top.equalTo(alexSection.snp_bottom).offset(10)
        }
        
        let allRights = label(view)
        allRights.font = NSFont(name: "HelveticaNeue", size: 11)
        allRights.stringValue = "All rights reserved."
        allRights.snp_makeConstraints { make in
            make.top.equalTo(copyright.snp_bottom)
            make.bottom.equalTo(view).offset(-17)
        }
    }
}
