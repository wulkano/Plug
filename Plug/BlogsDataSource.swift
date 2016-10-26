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
    
    func filterBlogs(_ contents: [AnyObject]) -> [HypeMachineAPI.Blog] {
        return contents.filter({ $0 is HypeMachineAPI.Blog }) as! [HypeMachineAPI.Blog]
    }
    
    func filterUniqueBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return Array(Set(blogs))
    }
    
    func filterBlogsMatchingSearchKeywords(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.filter { $0.name =~ self.searchKeywords! }
    }
    
    func filterFollowingBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.filter { $0.following == true }
    }
    
    func filterFeaturedBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.filter { $0.featured == true }
    }
    
    func sortBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [HypeMachineAPI.Blog] {
        return blogs.sort { $0.name.lowercaseString < $1.name.lowercaseString }
    }
    
    func groupBlogs(_ blogs: [HypeMachineAPI.Blog]) -> [AnyObject] {
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
    
    override func filterObjectsMatchingSearchKeywords(_ objects: [AnyObject]) -> [AnyObject] {
        let blogs = filterBlogs(objects)
        let uniqueBlogs = filterUniqueBlogs(blogs)
        let sortedBlogs = sortBlogs(uniqueBlogs)
        
        if searchKeywords == "" || searchKeywords == nil {
            print("Filtering, but no keywords present")
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
        HypeMachineAPI.Requests.Blogs.index { response in
            self.nextPageResultReceived(response.result)
        }
    }
    
    override func appendTableContents(_ contents: [AnyObject]) {
        let blogs = contents as! [HypeMachineAPI.Blog]
        let groupedBlogs = groupBlogs(blogs)
        super.appendTableContents(groupedBlogs)
    }
}

enum BlogDirectoryItem {
    case sectionHeaderItem(SectionHeader)
    case blogItem(HypeMachineAPI.Blog)
    
    static func fromObject(_ object: AnyObject) -> BlogDirectoryItem? {
        if object is HypeMachineAPI.Blog {
            return BlogDirectoryItem.BlogItem(object as! HypeMachineAPI.Blog)
        } else if object is SectionHeader {
            return BlogDirectoryItem.sectionHeaderItem(object as! SectionHeader)
        } else {
            return nil
        }
    }
}
