//
//  ColorChangingTextView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ColorChangingTextField: NSTextField {
    override var objectValue: AnyObject! {
        didSet { objectValueChanged() }
    }
    
    func objectValueChanged() {
        setColorForStringValue()
    }
    
    func setColorForStringValue() {
        let numberValue = self.numberValueForStringValue()
        var gradientLocation = self.gradientLocationForNumberValue(numberValue)
        var gradient = self.makeGradient()
        var newColor = gradient.interpolatedColorAtLocation(gradientLocation)
        self.textColor = newColor
    }
    
    func gradientLocationForNumberValue(numberValue: Int) -> CGFloat {
        let highEnd: CGFloat = 8000
        var location = CGFloat(numberValue) / highEnd
        if location > 1 {
            location = 1.0
        }
        return 1.0 - location
    }
    
    func numberValueForStringValue() -> Int {
        let escapedStringValue = stringValue.stringByReplacingOccurrencesOfString(",", withString: "", options: .LiteralSearch, range: nil)
        
        if escapedStringValue.hasSuffix("k") {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.format = "####k"
            let numberValue = numberFormatter.numberFromString(escapedStringValue)!.integerValue
            return numberValue * 1000
        } else {
            return escapedStringValue.toInt()!
        }
    }
    
    func makeGradient() -> NSGradient {
        let redColor = NSColor(red256: 255, green256: 95, blue256: 82)
        let purpleColor = NSColor(red256: 183, green256: 101, blue256: 212)
        let darkBlueColor = NSColor(red256: 28, green256: 121, blue256: 219)
        let lightBlueColor = NSColor(red256: 158, green256: 236, blue256: 255)
        return NSGradient(colorsAndLocations: (redColor, 0), (purpleColor, 0.333), (darkBlueColor, 0.666), (lightBlueColor, 1))
    }
}