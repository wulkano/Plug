//
//  ColorChangingTextView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class ColorChangingTextField: NSTextField {
    override var objectValue: Any! {
        didSet { objectValueChanged() }
    }

    func objectValueChanged() {
        setColorForStringValue()
    }

    func setColorForStringValue() {
        let numberValue = self.numberValueForStringValue()
        let gradientLocation = self.gradientLocationForNumberValue(numberValue)
        let gradient = self.makeGradient()
        let newColor = gradient.interpolatedColor(atLocation: gradientLocation)
        self.textColor = newColor
    }

    func gradientLocationForNumberValue(_ numberValue: Int) -> CGFloat {
        let highEnd: CGFloat = 8000
        var location = CGFloat(numberValue) / highEnd
        if location > 1 {
            location = 1.0
        }
        return 1.0 - location
    }

    func numberValueForStringValue() -> Int {
        let withoutCommas = stringValue.replacingOccurrences(of: ",", with: "", options: .literal, range: nil)
        let withoutPeriods = withoutCommas.replacingOccurrences(of: ".", with: "", options: .literal, range: nil)
        let withoutSpaces = withoutPeriods.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        let withoutSingleQuotes = withoutSpaces.replacingOccurrences(of: "'", with: "", options: .literal, range: nil)

        if withoutSingleQuotes.hasSuffix("k") {
            let numberFormatter = NumberFormatter()
            numberFormatter.format = "####k"
            let numberValue = numberFormatter.number(from: withoutSingleQuotes)!.intValue
            return numberValue * 1000
        } else {
            return Int(withoutSingleQuotes) ?? 0
        }
    }

    func makeGradient() -> NSGradient {
        let redColor = NSColor(red256: 255, green256: 95, blue256: 82)
        let purpleColor = NSColor(red256: 183, green256: 101, blue256: 212)
        let darkBlueColor = NSColor(red256: 28, green256: 121, blue256: 219)
        let lightBlueColor = NSColor(red256: 158, green256: 236, blue256: 255)
        return NSGradient(colorsAndLocations: (redColor, 0), (purpleColor, 0.333), (darkBlueColor, 0.666), (lightBlueColor, 1))!
    }
}
