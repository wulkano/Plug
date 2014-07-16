//
//  MainViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/16/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController, SidebarViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playlistViewController = childViewControllers[1] as PlaylistViewController
        HypeMachineAPI.Playlists.popularNow({playlist in
            playlistViewController.playlist = playlist
        }, failure: {error in
            println(error)
        })
    }
    
    func loadNavigationSection(section: NavigationSection) {
        switch section {
        case .Popular:
            switchPlaylistViews()
        case .Favorites:
            switchPlaylistViews()
        case .Latest:
            switchPlaylistViews()
        case .Feed:
            switchPlaylistViews()
        case .Search:
            switchPlaylistViews()
        }
    }
    
    func switchPlaylistViews() {
        let playlistViewController = childViewControllers[1] as PlaylistViewController
        let storyBoard = NSStoryboard(name: "Main", bundle: nil)
        let newPlaylistViewController = storyBoard.instantiateControllerWithIdentifier("PlaylistViewController") as PlaylistViewController
        newPlaylistViewController.playlist = playlistViewController.playlist
        addChildViewController(newPlaylistViewController)
        transitionFromViewController(playlistViewController, toViewController: newPlaylistViewController, options: NSViewControllerTransitionOptions.SlideLeft, completionHandler: nil)
    }
}
