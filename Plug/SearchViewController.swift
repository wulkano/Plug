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
//    var playlistSubType: SearchPlaylistSubType = .MostFavorites
    var tracksViewController: TracksViewController?
    var dataSource: TracksDataSource?
    override var analyticsViewName: String {
        return "MainWindow/Search"
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        if keywords == "" { return }

        ensurePlaylistViewController()
        tracksViewController!.dataSource = SearchTracksDataSource(searchQuery: keywords)
        tracksViewController!.dataSource!.viewController = tracksViewController
    }
    
    func ensurePlaylistViewController() {
        if tracksViewController == nil {
            tracksViewController = (storyboard!.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController)
            addChildViewController(tracksViewController!)
            ViewPlacementHelper.AddFullSizeSubview(tracksViewController!.view, toSuperView: searchResultsView)
        }
    }
    
    override func addLoaderView() {}
    
    override func refresh() {
        if tracksViewController != nil {
            tracksViewController!.refresh()
        }
    }
}
