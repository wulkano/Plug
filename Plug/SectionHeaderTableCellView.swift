//
//  SectionHeaderTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 10/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SectionHeaderTableCellView: NSTableCellView {
    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
        }
    }
    var sectionHeaderValue: SectionHeader {
        return objectValue as SectionHeader
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
        updateTitle()
    }
    
    func updateTitle() {
        textField!.stringValue = sectionHeaderValue.title
    }
}
