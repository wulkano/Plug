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
        if searchKeywords == "" || searchKeywords == nil {
            filtering = false
        } else {
            filtering = true
        }
    }
    
    func filterObjectsMatchingSearchKeywords(objects: [AnyObject]) -> [AnyObject] {
        fatalError("filterObjectsMatchingKeywords: not implemented")
    }
    
    // MARK: HypeMachineDataSource
    
    override func filterTableContents(objects: [AnyObject]) -> [AnyObject] {
        return filterObjectsMatchingSearchKeywords(objects)
    }
}
