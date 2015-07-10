//
//  DisplayErrorViewController.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class DisplayErrorViewController: NSViewController {
    let error: NSError
    
    var errorTitleTextField: NSTextField!
    var errorDescriptionTextField: NSTextField!
    
    init!(error: NSError) {
        self.error = error
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        let background = BackgroundBorderView()
        background.background = true
        background.backgroundColor = NSColor(red256: 255, green256: 95, blue256: 82)
        view.addSubview(background)
        background.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        errorTitleTextField = NSTextField(frame: NSZeroRect)
        errorTitleTextField.stringValue = "Error"
        errorTitleTextField.bordered = false
        errorTitleTextField.drawsBackground = false
        errorTitleTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)!
        (errorTitleTextField.cell() as! NSTextFieldCell).textColor = NSColor.whiteColor()
        view.addSubview(errorTitleTextField)
        errorTitleTextField.snp_makeConstraints { make in
            make.top.equalTo(self.view).offset(6)
            make.left.equalTo(self.view).offset(14)
            make.right.equalTo(self.view).offset(14)
        }
        
        errorDescriptionTextField = NSTextField(frame: NSZeroRect)
        errorDescriptionTextField.stringValue = "Oops"
        errorDescriptionTextField.bordered = false
        errorDescriptionTextField.drawsBackground = false
        errorDescriptionTextField.font = NSFont(name: "HelveticaNeue", size: 13)!
        (errorDescriptionTextField.cell() as! NSTextFieldCell).textColor = NSColor.whiteColor()
        view.addSubview(errorDescriptionTextField)
        errorDescriptionTextField.snp_makeConstraints { make in
            make.top.equalTo(errorTitleTextField.snp_bottom)
            make.left.equalTo(self.view).offset(14)
            make.right.equalTo(self.view).offset(14)
        }
        
        view.snp_makeConstraints { make in
            make.height.equalTo(6 + errorTitleTextField.intrinsicContentSize.height + errorDescriptionTextField.intrinsicContentSize.height + 14)
        }
    }
}
