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
    var sort: SearchSectionSort = .Newest {
        didSet {
            sortChanged()
        }
    }
    var tracksViewController: TracksViewController?
    var dataSource: TracksDataSource?
    
    override var analyticsViewName: String {
        return "MainWindow/Search"
    }
    
    @IBAction func searchFieldSubmit(sender: NSSearchField) {
        let keywords = sender.stringValue
        if keywords == "" { return }

        ensurePlaylistViewController()
        tracksViewController!.dataSource = SearchTracksDataSource(viewController: tracksViewController!, sort: sort, searchQuery: keywords)
    }
    
    func ensurePlaylistViewController() {
        if tracksViewController == nil {
            tracksViewController = (storyboard!.instantiateControllerWithIdentifier("TracksViewController") as! TracksViewController)
            addChildViewController(tracksViewController!)
            searchResultsView.addSubview(tracksViewController!.view)
            tracksViewController!.view.snp_makeConstraints { make in
                make.edges.equalTo(searchResultsView)
            }
        }
    }
    
    override func addLoaderView() {}
    
    override func refresh() {
        if tracksViewController != nil {
            tracksViewController!.refresh()
        }
    }
    
    func sortChanged() {
        if tracksViewController == nil || tracksViewController!.dataSource == nil { return }
        
        let searchDataSource = tracksViewController!.dataSource! as! SearchTracksDataSource
        tracksViewController!.dataSource = SearchTracksDataSource(viewController: tracksViewController!, sort: sort, searchQuery: searchDataSource.searchQuery)
    }
}
