//
//  SidebarViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {
    @IBOutlet var popularNavButton: NavigationButton
    @IBOutlet var favoritesNavButton: NavigationButton
    @IBOutlet var latestNavButton: NavigationButton
    @IBOutlet var feedNavButton: NavigationButton
    @IBOutlet var searchNavButton: NavigationButton
    var delegate: SidebarViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        toggleAllNavButtonsOffExcept(popularNavButton)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        delegate = parentViewController as MainViewController
    }
    
    @IBAction func popularNavButtonClick(sender: NavigationButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Popular)
    }
    @IBAction func favoritesNavButtonClick(sender: NavigationButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Favorites)
    }
    @IBAction func latestNavButtonClick(sender: NavigationButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Latest)
    }
    @IBAction func feedNavButtonClick(sender: NavigationButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Feed)
    }
    @IBAction func searchNavButtonClick(sender: NavigationButton) {
        toggleAllNavButtonsOffExcept(sender)
        delegate?.loadNavigationSection(NavigationSection.Search)
    }
    
    func allNavButtons() -> [NavigationButton] {
        return [
            popularNavButton,
            favoritesNavButton,
            latestNavButton,
            feedNavButton,
            searchNavButton,
        ]
    }
    
    func toggleAllNavButtonsOffExcept(selectedButton: NavigationButton) {
        for navButton in allNavButtons() {
            if navButton === selectedButton {
                navButton.buttonState = NavigationButtonState.Selected
            } else {
                navButton.buttonState = NavigationButtonState.Inactive
            }
        }
    }
}

enum NavigationSection: Int {
    case Popular
    case Favorites
    case Latest
    case Feed
    case Search
}

protocol SidebarViewControllerDelegate {
    func loadNavigationSection(section: NavigationSection)
}
