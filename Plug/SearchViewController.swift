//
//  SearchViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SearchViewController: NSViewController {
    @IBOutlet var searchResultsView: NSView!
    var playlistSubType: SearchPlaylistSubType = SearchPlaylistSubType.MostFavorites
    var playlistViewController: PlaylistViewController!
    var dataSource: SearchPlaylistDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        addPlaylistViewController()
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        if keywords == "" { return }

        dataSource = SearchPlaylistDataSource(searchKeywords: keywords, playlistSubType: playlistSubType)
        playlistViewController!.setDataSource(dataSource!)
    }
    
    func addPlaylistViewController() {
        playlistViewController = (storyboard.instantiateControllerWithIdentifier("PlaylistViewController") as PlaylistViewController)
        
        addChildViewController(playlistViewController)
        
        playlistViewController.view.translatesAutoresizingMaskIntoConstraints = false
        searchResultsView.addSubview(playlistViewController.view)
        
        var constraints = NSLayoutConstraint.constraintsWithVisualFormat("|[view]|", options: nil, metrics: nil, views: ["view": playlistViewController.view])
        searchResultsView.addConstraints(constraints)
        constraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view": playlistViewController.view])
        searchResultsView.addConstraints(constraints)
    }
}
