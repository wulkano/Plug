//
//  BlogTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 10/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogTableCellView: IOSStyleTableCellView {
    @IBOutlet var nameTextField: NSTextField!
    
    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
        }
    }
    var blogValue: Blog {
        return objectValue as Blog
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
        updateName()
    }
    
    func updateName() {
        nameTextField.stringValue = blogValue.name
    }
}
