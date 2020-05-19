//
//  FontHelper.swift
//  Plug
//
//  Created by Alex Marchant on 11/23/15.
//  Copyright © 2015 Plug. All rights reserved.
//

import Foundation


func appFont(size: CGFloat) -> NSFont {
    NSFont.systemFont(ofSize: size)
}

func appFont(size: CGFloat, weight: AppFontWeight) -> NSFont {
    if #available(OSX 10.11, *) {
		return NSFont.systemFont(ofSize: size, weight: NSFont.Weight(rawValue: weight.NSFontWeight))
    } else {
        var fontName = "HelveticaNeue"

        if let suffix = weight.stringSuffix {
            fontName += "-" + suffix
        }

        return NSFont(name: fontName, size: size)!
    }
}

enum AppFontWeight {
    case regular
    case medium
    case bold

    var NSFontWeight: CGFloat {
        if #available(OSX 10.11, *) {
            switch self {
            case .regular:
				return NSFont.Weight.regular.rawValue
            case .medium:
				return NSFont.Weight.medium.rawValue
            case .bold:
				return NSFont.Weight.bold.rawValue
            }
        } else {
            fatalError("This function is not available on your platform")
        }
    }

    var stringSuffix: String? {
        switch self {
        case .regular:
            return nil
        case .medium:
            return "Medium"
        case .bold:
            return "Bold"
        }
    }
}
