//
//  SidebarViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SidebarViewController: NSViewController {
    
    var mainViewController: MainViewController {
        return parentViewController as MainViewController
    }
    
    @IBAction func popularButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Popular)
        toggleAllButtonsOffExcept(sender)
    }
    
    @IBAction func favoritesButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Favorites)
        toggleAllButtonsOffExcept(sender)
    }
    
    @IBAction func latestButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Latest)
        toggleAllButtonsOffExcept(sender)
    }
    
    @IBAction func blogsButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Blogs)
        toggleAllButtonsOffExcept(sender)
    }
    
    @IBAction func feedButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Feed)
        toggleAllButtonsOffExcept(sender)
    }
    
    @IBAction func genresButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Genres)
        toggleAllButtonsOffExcept(sender)
    }
    
    @IBAction func friendsButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Friends)
        toggleAllButtonsOffExcept(sender)
    }
    
    @IBAction func searchButtonClicked(sender: AnyObject) {
        mainViewController.changeNavigationSection(.Search)
        toggleAllButtonsOffExcept(sender)
    }
    
    func toggleAllButtonsOffExcept(sender: AnyObject) {
        for button in allButtons() {
            if button === sender {
                button.state = NSOnState
            } else {
                button.state = NSOffState
            }
        }
    }
    
    func allButtons() -> [NSButton] {
        let visualEffectsView = view.subviews[0] as NSView
        return visualEffectsView.subviews as [NSButton]
    }
}
