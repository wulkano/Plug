//
//  GenresTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 10/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GenresTableCellView: IOSStyleTableCellView {
    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
        }
    }
    var genreValue: Genre {
        return objectValue as! Genre
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
        updateName()
    }
    
    func updateName() {
        textField!.stringValue = genreValue.name
    }
}
