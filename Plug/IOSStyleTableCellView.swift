//
//  IOSStyleTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class IOSStyleTableCellView: NSTableCellView {
    override var backgroundStyle: NSBackgroundStyle {
        get { return NSBackgroundStyle.light }
        set {}
    }
}
