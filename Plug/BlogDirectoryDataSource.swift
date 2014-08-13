//
//  BlogDirectoryDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogDirectoryDataSource: NSObject, NSTableViewDataSource {
    var tableView: NSTableView?
    var tableContents: [BlogDirectoryItem]?
    
    // TODO: Sorting
    // TODO: Grouping
    func loadInitialValues() {
        HypeMachineAPI.Blogs.AllBlogs(
            {blogs in
                self.tableContents = BlogDirectoryItem.WrapBlogObjects(blogs)
                self.tableView?.reloadData()
            }, failure: {error in
                AppError.logError(error)
        })
    }
    
    func itemForRow(row: Int) -> BlogDirectoryItem {
        return tableContents![row]
    }
    
    func tableView(tableView: NSTableView!, objectValueForTableColumn tableColumn: NSTableColumn!, row: Int) -> AnyObject! {
        switch itemForRow(row) {
        case .SectionHeaderItem(let sectionHeader):
            return sectionHeader
        case .BlogItem(let blog):
            return blog
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView!) -> Int {
        if tableContents == nil { return 0 }
        
        return tableContents!.count
    }
}

enum BlogDirectoryItem {
    case SectionHeaderItem(SectionHeader)
    case BlogItem(Blog)
    
    static func WrapBlogObjects(blogs: [Blog]) -> [BlogDirectoryItem] {
        var blogItems = [BlogDirectoryItem]()
        for blog in blogs {
            blogItems.append(.BlogItem(blog))
        }
        return blogItems
    }
}
