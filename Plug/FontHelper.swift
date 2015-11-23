//
//  FontHelper.swift
//  Plug
//
//  Created by Alex Marchant on 11/23/15.
//  Copyright © 2015 Plug. All rights reserved.
//

import Foundation


func appFont(size size: CGFloat) -> NSFont {
    return NSFont.systemFontOfSize(size)
}

func appFont(size size: CGFloat, weight: AppFontWeight) -> NSFont {
    if #available(OSX 10.11, *) {
        return NSFont.systemFontOfSize(size, weight: weight.NSFontWeight)
    } else {
        var fontName = "HelveticaNeue"
        
        if let suffix = weight.stringSuffix {
            fontName += "-" + suffix
        }
        
        return NSFont(name: fontName, size: size)!
    }
}

enum AppFontWeight {
    case Regular
    case Medium
    case Bold
    
    var NSFontWeight: CGFloat {
        if #available(OSX 10.11, *) {
            switch self {
            case .Regular:
                return NSFontWeightRegular
            case .Medium:
                return NSFontWeightMedium
            case .Bold:
                return NSFontWeightBold
            }
        } else {
            fatalError("This function is not available on your platform")
        }
    }
    
    var stringSuffix: String? {
        switch self {
        case .Regular:
            return nil
        case .Medium:
            return "Medium"
        case .Bold:
            return "Bold"
        }
    }
}