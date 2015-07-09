//
//  NavigationBar.swift
//  navigationControllers
//
//  Created by Alex Marchant on 9/2/14.
//  Copyright (c) 2014 alexmarchant. All rights reserved.
//

import Cocoa

class NavigationBarController: NSViewController {
    @IBOutlet var backButton: SwissArmyButton!
    @IBOutlet var titleTextField: NSTextField!
    @IBOutlet var titleDropdownButton: TitleBarPopUpButton!
    @IBOutlet var actionButton: ActionButton!
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        let backgroundView = NSVisualEffectView(frame: NSZeroRect)
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
            make.left.equalTo(backgroundView).offset(4)
            make.height.equalTo(22)
        }
        
        actionButton = ActionButton(frame: NSZeroRect)
        let actionCell = ActionButtonCell(textCell: "")
        actionButton.setCell(actionCell)
        actionButton.bezelStyle = .RegularSquareBezelStyle
        actionButton.bordered = true
        actionButton.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
        backgroundView.addSubview(actionButton)
        actionButton.snp_makeConstraints { make in
            make.centerY.equalTo(backgroundView).offset(-1)
            make.right.equalTo(backgroundView).offset(-6)
            make.height.equalTo(22)
        }
        
        titleTextField = NSTextField()
        titleTextField.editable = false
        titleTextField.selectable = false
        titleTextField.bordered = false
        titleTextField.drawsBackground = false
        titleTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)!
        backgroundView.addSubview(titleTextField)
        titleTextField.snp_makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalTo(backgroundView).offset(-1)
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
        backgroundView.addSubview(titleDropdownButton)
        titleDropdownButton.snp_makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalTo(backgroundView).offset(-1)
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
        viewController.actionButton = actionButton
        actionButton.onStateTitle = viewController.actionButtonOnTitle
        actionButton.offStateTitle = viewController.actionButtonOffTitle
        actionButton.state = viewController.actionButtonDefaultState
        actionButton.hidden = !viewController.displayActionButton
        actionButton.target = viewController.actionButtonTarget
        if let action = viewController.actionButtonAction {
            actionButton.action = action
        }
    }
    
    func updateBackButton(viewController: BaseContentViewController?) {
        if viewController == nil {
            backButton.hidden = true
            backButton.title = ""
        } else {
            backButton.hidden = false
            backButton.title = viewController!.title!
        }
    }
}
