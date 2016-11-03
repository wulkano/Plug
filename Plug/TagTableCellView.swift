//
//  GenresTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 10/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class TagTableCellView: IOSStyleTableCellView {
    var nameTextField: NSTextField!
    
    override var objectValue: Any! {
        didSet {
            objectValueChanged()
        }
    }
    var tagValue: HypeMachineAPI.Tag {
        return objectValue as! HypeMachineAPI.Tag
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
        updateName()
    }
    
    func updateName() {
        nameTextField.stringValue = tagValue.name
    }
}
