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
    @IBOutlet var favoritesNavButton: TransparentButton!
    @IBOutlet var latestNavButton: TransparentButton!
    @IBOutlet var blogsNavButton: TransparentButton!
    @IBOutlet var feedNavButton: TransparentButton!
    @IBOutlet var genresNavButton: TransparentButton!
    @IBOutlet var friendsNavButton: TransparentButton!
    @IBOutlet var searchNavButton: TransparentButton!
    @IBOutlet var sidebarOverlay: NSView!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "navigationSectionChanged:", name: Notifications.NavigationSectionChanged, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func navButtonClicked(sender: TransparentButton) {
        let section = sectionForButton(sender)
        changeNavigationSection(section)
    }
    
    func changeNavigationSection(section: NavigationSection) {
        NavigationSection.postChangeNotification(section, object: self)
        updateUIForSection(section)
    }
    
    func navigationSectionChanged(notification: NSNotification) {
        if notification.object === self { return }
        let section = NavigationSection.fromNotification(notification)
        updateUIForSection(section)
    }
    
    func updateUIForSection(section: NavigationSection) {
        let button = buttonForSection(section)
        toggleAllNavButtonsOffExcept(button)
    }
    
    func allNavButtons() -> [TransparentButton] {
        var navButtons = [TransparentButton]()
        for subview in sidebarOverlay.subviews {
            if subview is TransparentButton {
                navButtons.append(subview as TransparentButton)
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

    func buttonForSection(section: NavigationSection) -> TransparentButton {
        return buttonSectionMap()[section]!
    }
    
    func sectionForButton(button: TransparentButton) -> NavigationSection! {
        for (section, navButton) in buttonSectionMap() {
            if navButton === button {
                return section
            }
        }
        return nil
    }
    
    func buttonSectionMap() -> [NavigationSection: TransparentButton] {
        return [
            NavigationSection.Popular: popularNavButton,
            NavigationSection.Favorites: favoritesNavButton,
            NavigationSection.Latest: latestNavButton,
            NavigationSection.Blogs: blogsNavButton,
            NavigationSection.Feed: feedNavButton,
            NavigationSection.Genres: genresNavButton,
            NavigationSection.Friends: friendsNavButton,
            NavigationSection.Search: searchNavButton,
        ]
    }
}
