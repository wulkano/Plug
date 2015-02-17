//
//  GenresDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class GenresDataSource: MainContentDataSource {
    
    override func loadInitialValues() {
        HypeMachineAPI.Genres.AllGenres(
            {genres in
                self.generateTableContents(genres)
                self.viewController.tableView.reloadData()
                self.viewController.requestInitialValuesFinished()
            }, failure: {error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                Logger.LogError(error)
                self.viewController.requestInitialValuesFinished()
        })
    }
    
    func generateTableContents(genres: [Genre]) {
        standardTableContents.append(SectionHeader(title: "The Basics"))
        var priorityGenres = genres.filter { $0.priority == true }
        priorityGenres = priorityGenres.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        standardTableContents += priorityGenres as [AnyObject]
        
        standardTableContents.append(SectionHeader(title: "Everything"))
        var sortedGenres = genres.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        standardTableContents += sortedGenres as [AnyObject]
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            var filteredGenres = allGenres().filter { $0.name =~ keywords }
            var sortedGenres = filteredGenres.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
            filteredTableContents = filteredGenres
        }
        viewController.tableView.reloadData()
    }
    
    func allGenres() -> [Genre] {
        var results = [Genre]()
        for object in standardTableContents {
            if object is Genre {
                let genre = object as! Genre
                if find(results, genre) == nil {
                    results.append(genre)
                }
            }
        }
        return results
    }
}


enum GenresListItem {
    case SectionHeaderItem(SectionHeader)
    case GenreItem(Genre)
    
    static func fromObject(object: AnyObject) -> GenresListItem? {
        if object is Genre {
            return GenresListItem.GenreItem(object as! Genre)
        } else if object is SectionHeader {
            return GenresListItem.SectionHeaderItem(object as! SectionHeader)
        } else {
            return nil
        }
    }
}