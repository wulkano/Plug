//
//  SearchableDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 7/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class SearchableDataSource: HypeMachineDataSource {
    var searchKeywords: String? {
        didSet { searchKeywordsChanged() }
    }
    
    func searchKeywordsChanged() {
        refilterTableContents()
        
        if searchKeywords == "" || searchKeywords == nil {
            filtering = false
        } else {
            filtering = true
        }
    }
    
    func filterObjectsMatchingSearchKeywords(_ objects: [Any]) -> [Any] {
        fatalError("filterObjectsMatchingKeywords: not implemented")
    }
    
    // MARK: HypeMachineDataSource
    
    override func filterTableContents(_ objects: [Any]) -> [Any] {
        if searchKeywords == "" || searchKeywords == nil {
            return objects
        } else {
            return filterObjectsMatchingSearchKeywords(objects)
        }
    }
}
