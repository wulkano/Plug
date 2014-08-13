//
//  GenresDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GenresDataSource: NSObject, NSTableViewDataSource {
    var tableView: NSTableView?
    var tableContents: [GenresListItem]?
    
    // TODO: Sorting
    // TODO: Grouping
    func loadInitialValues() {
        HypeMachineAPI.Genres.AllGenres(
            {genres in
                self.generateTableContents(genres)
                self.tableView?.reloadData()
            }, failure: {error in
                AppError.logError(error)
        })
    }
    
    func itemForRow(row: Int) -> GenresListItem {
        return tableContents![row]
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
        
        return tableContents!.count
    }
    
    func generateTableContents(genres: [Genre]) {
        tableContents = [GenresListItem]()
        
        appendSectionHeader("The Basics")
        var priorityGenres = genres.filter { $0.priority == true }
        priorityGenres = priorityGenres.sorted { $0.name < $1.name }
        appendGenres(priorityGenres)
        
        appendSectionHeader("Everything")
        var sortedGenres = genres.sorted { $0.name < $1.name }
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