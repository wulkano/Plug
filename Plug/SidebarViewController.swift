//
//  SidebarViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {
    @IBOutlet var popularNavButton: TransparentButton!
    @IBOutlet var sidebarOverlay: NSView!
    var delegate: SidebarViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        TODO: Remove once bug fixed
        if popularNavButton {
            toggleAllNavButtonsOffExcept(popularNavButton)
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        delegate = parentViewController as MainViewController
    }
    
    @IBAction func popularNavButtonClick(sender: TransparentButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Popular)
    }
    @IBAction func favoritesNavButtonClick(sender: TransparentButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Favorites)
    }
    @IBAction func latestNavButtonClick(sender: TransparentButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Latest)
    }
    @IBAction func feedNavButtonClick(sender: TransparentButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Feed)
    }
    @IBAction func searchNavButtonClick(sender: TransparentButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Search)
    }
    
    func allNavButtons() -> [TransparentButton] {
        var navButtons = [TransparentButton]()
        for subview in sidebarOverlay.subviews {
            if subview is TransparentButton {
                navButtons += subview as TransparentButton
            }
        }
        return navButtons
    }
    
    func toggleAllNavButtonsOffExcept(selectedButton: TransparentButton) {
        for navButton in allNavButtons() {
            if navButton === selectedButton {
                navButton.selected = true
            } else {
                navButton.selected = false
            }
        }
    }
}

enum NavigationSection: Int {
    case Popular = 0
    case Favorites
    case Latest
    case Feed
    case Search
}

protocol SidebarViewControllerDelegate {
    func loadNavigationSection(section: NavigationSection)
}
