//
//  SearchViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class SearchViewController: BaseContentViewController {
    @IBOutlet var searchResultsView: NSView!
    var playlistSubType: SearchPlaylistSubType = .MostFavorites
    var playlistViewController: TracksViewController?
    var dataSource: SearchDataSource?
    override var analyticsViewName: String {
        return "MainWindow/Search"
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        if keywords == "" { return }

        ensurePlaylistViewController()
        playlistViewController!.dataSource = SearchDataSource(searchKeywords: keywords, playlistSubType: playlistSubType, viewController: playlistViewController!)
    }
    
    func ensurePlaylistViewController() {
        if playlistViewController == nil {
            playlistViewController = (storyboard!.instantiateControllerWithIdentifier("BasePlaylistViewController") as! TracksViewController)
            addChildViewController(playlistViewController!)
            ViewPlacementHelper.AddFullSizeSubview(playlistViewController!.view, toSuperView: searchResultsView)
        }
    }
    
    override func addLoaderView() {}
    
    override func refresh() {
        if playlistViewController != nil {
            playlistViewController!.refresh()
        }
    }
}
