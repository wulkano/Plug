//
//  GenresDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GenresDataSource: NSObject, NSTableViewDataSource {
    var viewController: GenresViewController
    var filtering: Bool = false
    var allGenres: [Genre]?
    var tableContents: [GenresListItem]?
    var filteredTableContents: [GenresListItem]?
    
    init(viewController: GenresViewController) {
        self.viewController = viewController
        super.init()
    }

    func loadInitialValues() {
        HypeMachineAPI.Genres.AllGenres(
            {genres in
                self.allGenres = genres
                self.generateTableContents(genres)
                self.viewController.tableView.reloadData()
                self.viewController.requestInitialValuesFinished()
            }, failure: {error in
                Notifications.Post.DisplayError(error, sender: self)
                Logger.LogError(error)
                self.viewController.requestInitialValuesFinished()
        })
    }
    
    func itemForRow(row: Int) -> GenresListItem {
        if filtering {
            return filteredTableContents![row]
        } else {
            return tableContents![row]
        }
    }
    
    func itemAfterRow(row: Int) -> GenresListItem? {
        var list: [GenresListItem]
        
        if filtering {
            list = filteredTableContents!
        } else {
            list = tableContents!
        }
        
        if list.count > row + 1{
            return itemForRow(row + 1)
        } else {
            return nil
        }
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        
        switch itemForRow(row) {
        case .SectionHeaderItem(let sectionHeader):
            return sectionHeader
        case .GenreItem(let genre):
            return genre
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if tableContents == nil { return 0 }
        
        if filtering {
            return filteredTableContents!.count
        } else {
            return tableContents!.count
        }
    }
    
    func generateTableContents(genres: [Genre]) {
        tableContents = [GenresListItem]()
        
        appendSectionHeader("The Basics")
        var priorityGenres = genres.filter { $0.priority == true }
        priorityGenres = priorityGenres.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        appendGenres(priorityGenres)
        
        appendSectionHeader("Everything")
        var sortedGenres = genres.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        appendGenres(sortedGenres)
    }
    
    func appendSectionHeader(title: String) {
        let sectionHeader = SectionHeader(title: title)
        let sectionHeaderItem = GenresListItem.SectionHeaderItem(sectionHeader)
        tableContents!.append(sectionHeaderItem)
    }
    
    func appendGenres(genres: [Genre]) {
        let wrappedGenres = GenresListItem.WrapGenreObjects(genres)
        tableContents! += wrappedGenres
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            var filteredGenres = allGenres!.filter {
                $0.name =~ keywords
            }
            var sortedGenres = filteredGenres.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
            filteredTableContents = GenresListItem.WrapGenreObjects(sortedGenres)
        }
        viewController.tableView.reloadData()
    }
}

enum GenresListItem {
    case SectionHeaderItem(SectionHeader)
    case GenreItem(Genre)
    
    static func WrapGenreObjects(genres: [Genre]) -> [GenresListItem] {
        var genreItems = [GenresListItem]()
        for genre in genres {
            genreItems.append(.GenreItem(genre))
        }
        return genreItems
    }
}