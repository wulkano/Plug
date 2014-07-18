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
        
        for child in childViewControllers {
            if child is NSTabViewController {
                tabViewController = child as? NSTabViewController
            }
        }
    }
    
    func loadNavigationSection(section: NavigationSection) {
        if tabViewController {
            tabViewController!.selectedTabViewItemIndex = section.toRaw()
        }
    }
}
