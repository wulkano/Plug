//
//  DisplayErrorViewController.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import SnapKit

class DisplayErrorViewController: NSViewController {
    let error: NSError
    
    var errorTitleTextField: NSTextField!
    var errorDescriptionTextField: NSTextField!
    
    var bottomConstraint: Constraint?
    var topConstraint: Constraint?
    
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
        errorTitleTextField.editable = false
        errorTitleTextField.selectable = false
        errorTitleTextField.bordered = false
        errorTitleTextField.drawsBackground = false
        errorTitleTextField.lineBreakMode = .ByWordWrapping
        errorTitleTextField.font = appFont(size: 14, weight: .Medium)
        errorTitleTextField.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
        errorTitleTextField.textColor = NSColor.whiteColor()
        view.addSubview(errorTitleTextField)
        errorTitleTextField.snp_makeConstraints { make in
            make.top.equalTo(view).offset(6)
            make.left.equalTo(view).offset(14)
            make.right.equalTo(view).offset(-14)
        }
        
        errorDescriptionTextField = NSTextField(frame: NSZeroRect)
        errorDescriptionTextField.stringValue = error.localizedDescription
        errorDescriptionTextField.editable = false
        errorDescriptionTextField.selectable = false
        errorDescriptionTextField.bordered = false
        errorDescriptionTextField.drawsBackground = false
        errorDescriptionTextField.lineBreakMode = .ByWordWrapping
        errorDescriptionTextField.font = appFont(size: 13)
        errorDescriptionTextField.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
        errorDescriptionTextField.textColor = NSColor.whiteColor()
        view.addSubview(errorDescriptionTextField)
        errorDescriptionTextField.snp_makeConstraints { make in
            make.top.equalTo(errorTitleTextField.snp_bottom)
            make.left.equalTo(view).offset(14)
            make.right.equalTo(view).offset(-14)
            make.bottom.equalTo(view).offset(-14)
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        errorTitleTextField.preferredMaxLayoutWidth = errorTitleTextField.frame.size.width
        errorDescriptionTextField.preferredMaxLayoutWidth = errorDescriptionTextField.frame.size.width
        view.layoutSubtreeIfNeeded()
    }
    
    func setupLayoutInSuperview() {
        view.snp_makeConstraints { make in
            bottomConstraint = make.bottom.equalTo(view.superview!.snp_top).constraint
            make.left.equalTo(view.superview!)
            make.right.equalTo(view.superview!)
        }
    }
    
    func animateIn() {
        view.superview!.layoutSubtreeIfNeeded()
        
        bottomConstraint!.uninstall()
        
        view.snp_makeConstraints { make in
            topConstraint = make.top.equalTo(view.superview!).constraint
        }
        
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = 0.25
                context.allowsImplicitAnimation = true
                context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                self.view.superview!.layoutSubtreeIfNeeded()
            }, completionHandler: nil)
    }
    
    func animateOutWithDelay(delay: Double, completionHandler: ()->Void) {
        Interval.single(delay) {
            self.view.superview!.layoutSubtreeIfNeeded()
            
            self.topConstraint!.uninstall()
            
            self.view.snp_makeConstraints { make in
                make.bottom.equalTo(self.view.superview!.snp_top)
            }
            
            NSAnimationContext.runAnimationGroup(
                { context in
                    context.duration = 0.25
                    context.allowsImplicitAnimation = true
                    context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                    self.view.superview!.layoutSubtreeIfNeeded()
                }, completionHandler: {
                    completionHandler()
            })
        }
    }
}