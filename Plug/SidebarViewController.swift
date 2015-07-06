//
//  SidebarViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {
    let delegate: SidebarViewControllerDelegate
    var buttons: [NavigationSectionButton] = []
    
    init?(delegate: SidebarViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView(frame: NSZeroRect)
        
        let backgroundView = DraggableVisualEffectsView()
        backgroundView.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
        view.addSubview(backgroundView)
        backgroundView.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        loadButtons(superview: backgroundView)
    }
    
    func loadButtons(#superview: NSView) {
        var n = 0
        while let navigationSection = NavigationSection(rawValue: n) {
            let button = NavigationSectionButton(navigationSection: navigationSection)
            button.target = self
            button.action = "navigationSectionButtonClicked:"
            superview.addSubview(button)
            
            button.snp_makeConstraints { make in
                make.centerX.equalTo(superview)
                make.width.equalTo(30)
                make.height.equalTo(30)
                
                if n == 0 {
                    make.top.equalTo(superview).offset(53)
                } else {
                    let previousButton = buttons[n - 1]
                    make.top.equalTo(previousButton.snp_bottom).offset(28)
                }
            }
            
            buttons.append(button)
            n++
        }
        
        buttons[0].state = NSOnState
    }
    
    func navigationSectionButtonClicked(sender: NavigationSectionButton) {
        delegate.changeNavigationSection(sender.navigationSection)
        toggleAllButtonsOffExcept(sender)
    }
    
    func toggleAllButtonsOffExcept(sender: AnyObject) {
        for button in buttons {
            if button === sender {
                button.state = NSOnState
            } else {
                button.state = NSOffState
            }
        }
    }
}

protocol SidebarViewControllerDelegate {
    func changeNavigationSection(section: NavigationSection)
}
