//
//  TagContainerView.swift
//  Plug
//
//  Created by Alex Marchant on 10/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TagContainerView: NSView {
    override var flipped: Bool {
        return true
    }
    let buttonSpacing: CGFloat = 4
    let buttonHeight: CGFloat = 24
    var tags: [Genre] = [] {
        didSet {
            updateTags()
        }
    }
    var buttons = [TagButton]()
    var delegate: TagContainerViewDelegate!
    
    func updateTags() {
        for tag in tags {
            let button = generateTagButtonForTag(tag)
            button.frame.origin = generateOriginForNewButton(button)
            addSubview(button)
            buttons.append(button)
            button.action = "tagButtonClick:"
            button.target = self
        }
        let heightConstraint = constraints.last as NSLayoutConstraint
        if let lastButton = buttons.last {
           heightConstraint.constant = lastButton.frame.origin.y + lastButton.frame.size.height
        } else {
            heightConstraint.constant = 0
        }
    }
    
    func generateTagButtonForTag(tag: Genre) -> TagButton {
        let tagButton = TagButton(frame: NSMakeRect(0, 0, 0, buttonHeight))
        tagButton.title = tag.name.uppercaseString
        tagButton.fillColor = getFillColorForTag(tag)
        var tagSize = tagButton.attributedTitle.size
        tagSize.width += 16
        tagButton.frame.size.width = tagSize.width
        return tagButton
    }
    
    func generateOriginForNewButton(button: TagButton) -> NSPoint {
        if let lastButton = buttons.last {
            if lastButton.frame.origin.x + lastButton.frame.size.width + buttonSpacing + button.frame.size.width > frame.size.width {
                return NSMakePoint(0, lastButton.frame.origin.y + buttonSpacing + buttonHeight)
            } else {
                return NSMakePoint(lastButton.frame.origin.x + lastButton.frame.size.width + buttonSpacing, lastButton.frame.origin.y)
            }
        } else {
            return NSMakePoint(0, 0)
        }
    }
    
    func getFillColorForTag(tag: Genre) -> NSColor {
        let gradient = makeGradient()
        let gradientLocation = gradientLocationForTag(tag)
        return gradient.interpolatedColorAtLocation(gradientLocation)
    }
    
    func gradientLocationForTag(tag: Genre) -> CGFloat {
        let index = find(tags, tag)!
        return CGFloat(index) / CGFloat((tags.count - 1))
    }
    
    func makeGradient() -> NSGradient {
        let redColor = NSColor(red256: 255, green256: 95, blue256: 82)
        let purpleColor = NSColor(red256: 183, green256: 101, blue256: 212)
        let darkBlueColor = NSColor(red256: 28, green256: 121, blue256: 219)
        let lightBlueColor = NSColor(red256: 158, green256: 236, blue256: 255)
        return NSGradient(colorsAndLocations: (redColor, 0), (purpleColor, 0.333), (darkBlueColor, 0.666), (lightBlueColor, 1))
    }
    
    func tagButtonClick(sender: TagButton) {
        let genre = genreForButton(sender)
        delegate.genreButtonClicked(genre)
    }

    func genreForButton(button: TagButton) -> Genre {
        let index = find(buttons, button)!
        return tags[index]
    }
}

protocol TagContainerViewDelegate {
    func genreButtonClicked(genre: Genre)
}
