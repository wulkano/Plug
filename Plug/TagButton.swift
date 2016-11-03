//
//  TagButton.swift
//  Plug
//
//  Created by Alex Marchant on 10/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TagButton: SwissArmyButton {
    var fillColor: NSColor {
        get { return tagButtonCell.fillColor }
        set { tagButtonCell.fillColor = newValue }
    }
    override var title: String {
        get { return attributedTitle.string }
        set { attributedTitle = NSAttributedString(string: newValue) }
    }
    override var attributedTitle: NSAttributedString {
        get { return super.attributedTitle }
        set {
            super.attributedTitle = NSAttributedString(string: newValue.string, attributes: fontAttributes())
        }
    }
    var tagButtonCell: TagButtonCell {
        return cell as! TagButtonCell
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupCell()
        setButtonType(NSButtonType.momentaryPushIn)
//        buttonType =
        bezelStyle = NSBezelStyle.regularSquare
    }
    
    override func setupCell() {
        let newCell = TagButtonCell(textCell: "")
        self.cell = newCell
    }
    
    func fontAttributes() -> [String: AnyObject] {
        var attributes = [String: AnyObject]()
        let color = NSColor.black
        let font = appFont(size: 12, weight: .bold)
        attributes[NSForegroundColorAttributeName] = color
        attributes[NSFontAttributeName] = font
        return attributes
    }
}
