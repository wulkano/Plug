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
    
    func loadInitialValues() {
        HypeMachineAPI.Blogs.AllBlogs(
            {blogs in
                self.generateTableContents(blogs)
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
    
    func generateTableContents(blogs: [Blog]) {
        tableContents = [BlogDirectoryItem]()
        
        var followingBlogs = blogs.filter { $0.following == true }
        if followingBlogs.count > 0 {
            appendSectionHeader("Following")
            followingBlogs = followingBlogs.sorted { $0.name < $1.name }
            appendBlogs(followingBlogs)
        }
        
        appendSectionHeader("Featured")
        var featuredBlogs = blogs.filter { $0.featured == true }
        featuredBlogs = featuredBlogs.sorted { $0.name < $1.name }
        appendBlogs(featuredBlogs)
        
        appendSectionHeader("All Blogs")
        var allBlogs = blogs.sorted { $0.name < $1.name }
        appendBlogs(allBlogs)
    }
    
    func appendSectionHeader(title: String) {
        let sectionHeader = SectionHeader(title: title)
        let sectionHeaderItem = BlogDirectoryItem.SectionHeaderItem(sectionHeader)
        tableContents!.append(sectionHeaderItem)
    }
    
    func appendBlogs(blogs: [Blog]) {
        let wrappedBlogs = BlogDirectoryItem.WrapBlogObjects(blogs)
        tableContents! += wrappedBlogs
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
