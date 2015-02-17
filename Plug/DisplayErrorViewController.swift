//
//  DisplayErrorViewController.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class DisplayErrorViewController: NSViewController {
    @IBOutlet weak var errorTitleTextField: NSTextField!
    @IBOutlet weak var errorDescriptionTextField: NSTextField!
    
    override var representedObject: AnyObject! {
        didSet {
            representedObjectChanged()
        }
    }
    var representedError: NSError {
        return representedObject as! NSError
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        representedObjectChanged()
    }
    
    func representedObjectChanged() {
        if representedObject == nil { return }
        if !viewLoaded { return }
        
        let title = "Error"
        var description = "Oop. Something went wrong."
        
        if representedError.userInfo![NSLocalizedDescriptionKey] != nil {
            description = representedError.localizedDescription
        }
        
        errorTitleTextField.stringValue = title
        errorDescriptionTextField.stringValue = description
    }
}
