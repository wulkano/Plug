//
//  BlogDirectoryDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class BlogDirectoryDataSource: MainContentDataSource {

    override func loadInitialValues() {
        HypeMachineAPI.Blogs.AllBlogs(
            {blogs in
                self.generateTableContents(blogs)
                self.viewController.tableView!.reloadData()
                self.viewController.requestInitialValuesFinished()
            }, failure: {error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                Logger.LogError(error)
                self.viewController.requestInitialValuesFinished()
        })
    }
    
    func generateTableContents(blogs: [Blog]) {
        standardTableContents = []
        
        var followingBlogs = blogs.filter { $0.following == true }
        if followingBlogs.count > 0 {
            standardTableContents.append(SectionHeader(title: "Following"))
            followingBlogs = followingBlogs.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
            standardTableContents += followingBlogs as [AnyObject]
        }
        
        standardTableContents.append(SectionHeader(title: "Featured"))
        var featuredBlogs = blogs.filter { $0.featured == true }
        featuredBlogs = featuredBlogs.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        standardTableContents += featuredBlogs as [AnyObject]

        standardTableContents.append(SectionHeader(title: "All Blogs"))
        var allBlogs = blogs.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        standardTableContents += allBlogs as [AnyObject]
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            var filteredBlogs = allBlogs().filter {
                $0.name =~ keywords
            }
            var sortedBlogs = filteredBlogs.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
            filteredTableContents = sortedBlogs as [AnyObject]
        }
        viewController.tableView!.reloadData()
    }
    
    func allBlogs() -> [Blog] {
        var results = [Blog]()
        for object in standardTableContents {
            if object is Blog {
                let blog = object as Blog
                if find(results, blog) == nil {
                    results.append(blog)
                }
            }
        }
        return results
    }
}

enum BlogDirectoryItem {
    case SectionHeaderItem(SectionHeader)
    case BlogItem(Blog)
    
    static func fromObject(object: AnyObject) -> BlogDirectoryItem? {
        if object is Blog {
            return BlogDirectoryItem.BlogItem(object as Blog)
        } else if object is SectionHeader {
            return BlogDirectoryItem.SectionHeaderItem(object as SectionHeader)
        } else {
            return nil
        }
    }
}