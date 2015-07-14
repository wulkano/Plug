//
//  BlogsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class BlogsDataSource: SearchableDataSource {
    
    func filterBlogs(contents: [AnyObject]) -> [HypeMachineAPI.Blog] {
        return contents.filter({ $0 is HypeMachineAPI.Blog }) as! [HypeMachineAPI.Blog]
    }
    
    func filterUniqueBlogs(blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return Array(Set(blogs))
    }
    
    func filterBlogsMatchingSearchKeywords(blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.filter { $0.name =~ self.searchKeywords! }
    }
    
    func filterFollowingBlogs(blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.filter { $0.following == true }
    }
    
    func filterFeaturedBlogs(blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.filter { $0.featured == true }
    }
    
    func sortBlogs(blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
    }
    
    func groupBlogs(blogs: [HypeMachineAPI.Blog]) -> [AnyObject] {
        var groupedBlogs: [AnyObject] = []
        
        let followingBlogs = filterFollowingBlogs(blogs)
        if followingBlogs.count > 0 {
            let sortedFollowingBlogs = sortBlogs(followingBlogs)
            groupedBlogs.append(SectionHeader(title: "Following"))
            groupedBlogs += sortedFollowingBlogs as [AnyObject]
        }
        
        let featuredBlogs = filterFeaturedBlogs(blogs)
        if featuredBlogs.count > 0 {
            let sortedFeaturedBlogs = sortBlogs(featuredBlogs)
            groupedBlogs.append(SectionHeader(title: "Featured"))
            groupedBlogs += sortedFeaturedBlogs as [AnyObject]
        }
        
        groupedBlogs.append(SectionHeader(title: "All Blogs"))
        let allSortedBlogs = sortBlogs(blogs)
        groupedBlogs += allSortedBlogs as [AnyObject]
        
        return groupedBlogs
    }
    
    // MARK: SearchableDataSource
    
    override func filterObjectsMatchingSearchKeywords(objects: [AnyObject]) -> [AnyObject] {
        let blogs = filterBlogs(objects)
        let uniqueBlogs = filterUniqueBlogs(blogs)
        let sortedBlogs = sortBlogs(blogs)
        
        if searchKeywords == "" || searchKeywords == nil {
            println("Filtering, but no keywords present")
            return sortedBlogs
        } else {
            return filterBlogsMatchingSearchKeywords(sortedBlogs)
        }
    }
    
    // MARK: HypeMachineDataSource
    
    override var singlePage: Bool {
        return true
    }
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Blogs.index(optionalParams: nil) { (blogs, error) in
            self.nextPageObjectsReceived(blogs, error: error)
        }
    }
    
    override func appendTableContents(contents: [AnyObject]) {
        let blogs = contents as! [HypeMachineAPI.Blog]
        let groupedBlogs = groupBlogs(blogs)
        super.appendTableContents(groupedBlogs)
    }
}

enum BlogDirectoryItem {
    case SectionHeaderItem(SectionHeader)
    case BlogItem(HypeMachineAPI.Blog)
    
    static func fromObject(object: AnyObject) -> BlogDirectoryItem? {
        if object is HypeMachineAPI.Blog {
            return BlogDirectoryItem.BlogItem(object as! HypeMachineAPI.Blog)
        } else if object is SectionHeader {
            return BlogDirectoryItem.SectionHeaderItem(object as! SectionHeader)
        } else {
            return nil
        }
    }
}