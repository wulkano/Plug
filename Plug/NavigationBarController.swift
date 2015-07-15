//
//  NavigationBar.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa
import SnapKit

class NavigationBarController: NSViewController {
    var backButton: SwissArmyButton!
    var titleTextField: NSTextField!
    var titleDropdownButton: TitleBarPopUpButton!
    var backgroundView: NSView!
    var currentActionButton: ActionButton?
    
    var backButtonWidthConstraint: Constraint?
    var actionButtonLeftConstraint1: Constraint?
    var actionButtonLeftConstraint2: Constraint?
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        backgroundView = NSVisualEffectView(frame: NSZeroRect)
        view.addSubview(backgroundView)
        backgroundView.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        let borderView = BackgroundBorderView()
        borderView.bottomBorder = true
        borderView.borderColor = NSColor(red256: 194, green256: 195, blue256: 196)
        backgroundView.addSubview(borderView)
        borderView.snp_makeConstraints { make in
            make.edges.equalTo(backgroundView)
        }
        
        backButton = SwissArmyButton(frame: NSZeroRect)
        let backCell = BackButtonCell(textCell: "")
        backButton.setCell(backCell)
        backButton.bezelStyle = .RegularSquareBezelStyle
        backButton.bordered = true
        backButton.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        backgroundView.addSubview(backButton)
        backButton.snp_makeConstraints { make in
            make.centerY.equalTo(backgroundView).offset(-1)
            make.left.equalTo(backgroundView).offset(6)
            make.height.equalTo(22)
        }
        
        titleTextField = NSTextField()
        titleTextField.editable = false
        titleTextField.selectable = false
        titleTextField.bordered = false
        titleTextField.drawsBackground = false
        titleTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)!
        titleTextField.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
        titleTextField.lineBreakMode = .ByTruncatingMiddle
        backgroundView.addSubview(titleTextField)
        titleTextField.snp_makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalTo(backgroundView).offset(-1)
            make.left.greaterThanOrEqualTo(backButton.snp_right).offset(10)
        }
        
        titleDropdownButton = TitleBarPopUpButton(frame: NSZeroRect, pullsDown: true)
        let dropdownCell = TitleBarPopUpButtonCell(textCell: "", pullsDown: true)
        dropdownCell.altersStateOfSelectedItem = true
        dropdownCell.usesItemFromMenu = true
        dropdownCell.arrowPosition = .ArrowAtBottom
        titleDropdownButton.setCell(dropdownCell)
        titleDropdownButton.hidden = true
        titleDropdownButton.autoenablesItems = true
        titleDropdownButton.preferredEdge = NSMaxYEdge
        titleDropdownButton.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
        titleDropdownButton.lineBreakMode = .ByTruncatingMiddle
        backgroundView.addSubview(titleDropdownButton)
        titleDropdownButton.snp_makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalTo(backgroundView).offset(-1)
            make.left.greaterThanOrEqualTo(backButton.snp_right).offset(10)
        }
    }
    
    func currentViewControllerUpdated(viewController: BaseContentViewController) {
        updateDropdownMenu(viewController)
        updateActionButton(viewController)
    }
    
    func previousViewControllerUpdated(viewController: BaseContentViewController?) {
        updateBackButton(viewController)
    }
    
    func updateDropdownMenu(viewController: BaseContentViewController) {
        if viewController.dropdownMenu != nil {
            titleTextField.hidden = true
            titleDropdownButton.hidden = false
            
            titleDropdownButton.menu = viewController.dropdownMenu
        } else {
            titleTextField.hidden = false
            titleDropdownButton.hidden = true
            
            titleTextField.stringValue = viewController.title!
        }
    }
    
    func updateActionButton(viewController: BaseContentViewController) {
        currentActionButton?.removeFromSuperview()
        
        if viewController.actionButton != nil {
            currentActionButton = viewController.actionButton
            
            backgroundView.addSubview(viewController.actionButton!)
            
            viewController.actionButton!.snp_makeConstraints { make in
                make.centerY.equalTo(backgroundView).offset(-1)
                make.right.equalTo(backgroundView).offset(-6)
                make.height.equalTo(22)
                actionButtonLeftConstraint1 = make.left.greaterThanOrEqualTo(titleDropdownButton.snp_right).offset(10).constraint
                actionButtonLeftConstraint2 = make.left.greaterThanOrEqualTo(titleTextField.snp_right).offset(10).constraint
            }
        } else {
            actionButtonLeftConstraint1?.uninstall()
            actionButtonLeftConstraint2?.uninstall()
            actionButtonLeftConstraint1 = nil
            actionButtonLeftConstraint2 = nil
        }
    }
    
    func updateBackButton(viewController: BaseContentViewController?) {
        if viewController == nil {
            backButton.title = ""
            backButton.snp_makeConstraints { make in
                backButtonWidthConstraint = make.width.equalTo(0).constraint
            }
        } else {
            backButton.title = viewController!.title!
            backButtonWidthConstraint?.uninstall()
            backButtonWidthConstraint = nil
        }
    }
}
