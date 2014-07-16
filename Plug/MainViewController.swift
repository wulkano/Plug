//
//  MainViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, SidebarViewControllerDelegate {
    var tabViewController: NSTabViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func loadNavigationSection(section: NavigationSection) {
        if tabViewController {
            tabViewController!.selectedTabViewItemIndex = section.toRaw()
        }
    }
}
