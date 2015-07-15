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
    let navigationController: NavigationController
    
    var items: [NavigationItem]?
    var topItem: NavigationItem? {
        return items?.last
    }
    var backItem: NavigationItem? {
        if items == nil || items!.count < 2 { return nil }
        
        return items![items!.count - 2]
    }
    
    var backgroundView: NSView!
    var navigationBarView: NSView?
    
    init?(navigationController: NavigationController) {
        self.navigationController = navigationController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pushNavigationItem(item: NavigationItem, animated: Bool) {
        if items == nil {
            items = []
        }
        
        items!.append(item)
        updateNavigationBarViews(animated: animated, direction: .RightToLeft)
    }
    
    func popNavigationItemAnimated(animated: Bool) -> NavigationItem? {
        if items == nil || items!.count <= 1 { return nil}
        
        let poppedItem = items!.removeAtIndex(items!.count - 1)
        updateNavigationBarViews(animated: animated, direction: .RightToLeft)
        return poppedItem
    }
    
    func popToNavigationItem(item: NavigationItem, animated: Bool) -> [NavigationItem]? {
        if items == nil || items!.count <= 1 { return nil}
        
        var poppedItems: [NavigationItem] = []
        var pastTargetItem = false
        
        for (index, i) in enumerate(items!) {
            if i === item {
                pastTargetItem = true
                continue
            }
            
            if pastTargetItem {
                poppedItems.append(i)
                items!.removeAtIndex(index)
            }
        }
        
        updateNavigationBarViews(animated: animated, direction: .RightToLeft)
        return poppedItems
    }
    
    func setNavigationItems(items: [NavigationItem]) {
        self.items = items
        updateNavigationBarViews(animated: false, direction: nil)
    }
    
    func updateNavigationBarViews(#animated: Bool, direction: TransitionDirection?) {
        navigationBarView?.removeFromSuperview()
        navigationBarView = nil
        addNavigationBarViewForCurrentItems()
    }
    
    func addNavigationBarViewForCurrentItems(){
        let buttonEdgeSpacing: CGFloat = 6
        let titleSpacing: CGFloat = 10
        let buttonYOffset: CGFloat = -1
        let titleYOffset: CGFloat = -1
        
        navigationBarView = NSView()
        backgroundView.addSubview(navigationBarView!)
        navigationBarView!.snp_makeConstraints { make in
            make.edges.equalTo(backgroundView)
        }

        // Back button section
        var backButton: NSButton?
        
        if backItem != nil {
            backButton = NavigationItem.standardBackButtonWithTitle(backItem!.title)
            backButton!.target = self
            backButton!.action = "backButtonClicked:"
            navigationBarView!.addSubview(backButton!)
            backButton!.snp_makeConstraints{ make in
                make.centerY.equalTo(navigationBarView!).offset(buttonYOffset)
                make.left.equalTo(navigationBarView!).offset(buttonEdgeSpacing)
                make.height.equalTo(22)
            }
        }
        
        // Right button section
        if topItem!.rightButton != nil {
            navigationBarView!.addSubview(topItem!.rightButton!)
            topItem!.rightButton!.snp_makeConstraints { make in
                make.centerY.equalTo(navigationBarView!).offset(buttonYOffset)
                make.right.equalTo(navigationBarView!).offset(-buttonEdgeSpacing)
                make.height.equalTo(22)
            }
        }
        
        // Title section
        var titleView: NSView
        
        if topItem!.titleView != nil {
            titleView = topItem!.titleView!
        } else {
            titleView = textFieldForTitle(topItem!.title)
        }
        
        navigationBarView!.addSubview(titleView)
        titleView.snp_makeConstraints { make in
            make.centerX.equalTo(backgroundView)
            make.centerY.equalTo(backgroundView).offset(titleYOffset)
            
            if backButton != nil {
                make.left.greaterThanOrEqualTo(backButton!.snp_right).offset(titleSpacing)
            } else {
                make.left.greaterThanOrEqualTo(navigationBarView!).offset(titleSpacing)
            }
            
            if topItem!.rightButton != nil {
                make.right.lessThanOrEqualTo(topItem!.rightButton!.snp_left).offset(-titleSpacing)
            } else {
                make.right.lessThanOrEqualTo(navigationBarView!).offset(-titleSpacing)
            }
        }
    }
    
    func textFieldForTitle(title: String) -> NSTextField {
        let textField = NSTextField()
        textField.editable = false
        textField.selectable = false
        textField.bordered = false
        textField.drawsBackground = false
        textField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)!
        textField.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
        textField.lineBreakMode = .ByTruncatingMiddle
        textField.stringValue = title
        return textField
    }
    
    // MARK: NSViewController
    
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
    }
//
//        backButton = SwissArmyButton(frame: NSZeroRect)
//        let backCell = BackButtonCell(textCell: "")
//        backButton.setCell(backCell)
//        backButton.bezelStyle = .RegularSquareBezelStyle
//        backButton.bordered = true
//        backButton.font = NSFont(name: "HelveticaNeue-Medium", size: 13)!
//        backgroundView.addSubview(backButton)
//        backButton.snp_makeConstraints { make in
//            make.centerY.equalTo(backgroundView).offset(-1)
//            make.left.equalTo(backgroundView).offset(6)
//            make.height.equalTo(22)
//        }
//        
//        titleTextField = NSTextField()
//        titleTextField.editable = false
//        titleTextField.selectable = false
//        titleTextField.bordered = false
//        titleTextField.drawsBackground = false
//        titleTextField.font = NSFont(name: "HelveticaNeue-Medium", size: 14)!
//        titleTextField.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
//        titleTextField.lineBreakMode = .ByTruncatingMiddle
//        backgroundView.addSubview(titleTextField)
//        titleTextField.snp_makeConstraints { make in
//            make.centerX.equalTo(backgroundView)
//            make.centerY.equalTo(backgroundView).offset(-1)
//            make.left.greaterThanOrEqualTo(backButton.snp_right).offset(10)
//        }
//        
//        titleDropdownButton = TitleBarPopUpButton(frame: NSZeroRect, pullsDown: true)
//        let dropdownCell = TitleBarPopUpButtonCell(textCell: "", pullsDown: true)
//        dropdownCell.altersStateOfSelectedItem = true
//        dropdownCell.usesItemFromMenu = true
//        dropdownCell.arrowPosition = .ArrowAtBottom
//        titleDropdownButton.setCell(dropdownCell)
//        titleDropdownButton.hidden = true
//        titleDropdownButton.autoenablesItems = true
//        titleDropdownButton.preferredEdge = NSMaxYEdge
//        titleDropdownButton.setContentCompressionResistancePriority(490, forOrientation: .Horizontal)
//        titleDropdownButton.lineBreakMode = .ByTruncatingMiddle
//        backgroundView.addSubview(titleDropdownButton)
//        titleDropdownButton.snp_makeConstraints { make in
//            make.centerX.equalTo(backgroundView)
//            make.centerY.equalTo(backgroundView).offset(-1)
//            make.left.greaterThanOrEqualTo(backButton.snp_right).offset(10)
//        }
//    }
//    
//    func currentViewControllerUpdated(viewController: BaseContentViewController) {
//        updateDropdownMenu(viewController)
//        updateActionButton(viewController)
//    }
//    
//    func previousViewControllerUpdated(viewController: BaseContentViewController?) {
//        updateBackButton(viewController)
//    }
//    
//    func updateDropdownMenu(viewController: BaseContentViewController) {
//        if viewController.dropdownMenu != nil {
//            titleTextField.hidden = true
//            titleDropdownButton.hidden = false
//            
//            titleDropdownButton.menu = viewController.dropdownMenu
//        } else {
//            titleTextField.hidden = false
//            titleDropdownButton.hidden = true
//            
//            titleTextField.stringValue = viewController.title!
//        }
//    }
//    
//    func updateActionButton(viewController: BaseContentViewController) {
//        currentActionButton?.removeFromSuperview()
//        
//        if viewController.navigationItem!.rightButton != nil {
//            currentActionButton = viewController.navigationItem!.rightButton
//            
//            backgroundView.addSubview(viewController.navigationItem!.rightButton!)
//            
//            viewController.navigationItem!.rightButton!.snp_makeConstraints { make in
//                make.centerY.equalTo(backgroundView).offset(-1)
//                make.right.equalTo(backgroundView).offset(-6)
//                make.height.equalTo(22)
//                actionButtonLeftConstraint1 = make.left.greaterThanOrEqualTo(titleDropdownButton.snp_right).offset(10).constraint
//                actionButtonLeftConstraint2 = make.left.greaterThanOrEqualTo(titleTextField.snp_right).offset(10).constraint
//            }
//        } else {
//            actionButtonLeftConstraint1?.uninstall()
//            actionButtonLeftConstraint2?.uninstall()
//            actionButtonLeftConstraint1 = nil
//            actionButtonLeftConstraint2 = nil
//        }
//    }
//    
//    func updateBackButton(viewController: BaseContentViewController?) {
//        if viewController == nil {
//            backButton.title = ""
//            backButton.snp_makeConstraints { make in
//                backButtonWidthConstraint = make.width.equalTo(0).constraint
//            }
//        } else {
//            backButton.title = viewController!.title!
//            backButtonWidthConstraint?.uninstall()
//            backButtonWidthConstraint = nil
//        }
//    }
    
    // MARK: Actions
    
    func backButtonClicked(sender: NSButton) {
        navigationController.popViewController()
    }
}

enum TransitionDirection {
    case LeftToRight
    case RightToLeft
}