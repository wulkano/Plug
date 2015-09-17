//
//  TagsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class TagsDataSource: SearchableDataSource {
    
    func filterTags(contents: [AnyObject]) -> [HypeMachineAPI.Tag] {
        return contents.filter({ $0 is HypeMachineAPI.Tag }) as! [HypeMachineAPI.Tag]
    }
    
    func filterUniqueTags(tags: [HypeMachineAPI.Tag]) -> [HypeMachineAPI.Tag] {
        return Array(Set(tags))
    }
    
    func filterTagsMatchingSearchKeywords(tags: [HypeMachineAPI.Tag]) -> [HypeMachineAPI.Tag] {
        return tags.filter { $0.name =~ self.searchKeywords! }
    }
    
    func sortTags(tags: [HypeMachineAPI.Tag]) -> [HypeMachineAPI.Tag] {
        return tags.sort { $0.name.lowercaseString < $1.name.lowercaseString }
    }
    
    func groupTags(tags: [HypeMachineAPI.Tag]) -> [AnyObject] {
        var groupedTags: [AnyObject] = []
        
        groupedTags.append(SectionHeader(title: "The Basics"))
        var priorityTags = tags.filter { $0.priority == true }
        priorityTags = priorityTags.sort { $0.name.lowercaseString < $1.name.lowercaseString }
        groupedTags += priorityTags as [AnyObject]
        
        groupedTags.append(SectionHeader(title: "Everything"))
        var sortedTags = tags.sort { $0.name.lowercaseString < $1.name.lowercaseString }
        groupedTags += sortedTags as [AnyObject]
        
        return groupedTags
    }
    
    // MARK: SearchableDataSource
    
    override func filterObjectsMatchingSearchKeywords(objects: [AnyObject]) -> [AnyObject] {
        let tags = filterTags(objects)
        let uniqueTags = filterUniqueTags(tags)
        let sortedTags = sortTags(uniqueTags)
        
        if searchKeywords == "" || searchKeywords == nil {
            print("Filtering, but no keywords present")
            return sortedTags
        } else {
            return filterTagsMatchingSearchKeywords(sortedTags)
        }
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Tags.index { (tags, error) in
            self.nextPageObjectsReceived(tags, error: error)
        }
    }
    
    override func appendTableContents(contents: [AnyObject]) {
        let tags = contents as! [HypeMachineAPI.Tag]
        let groupedTags = groupTags(tags)
        super.appendTableContents(groupedTags)
    }
}


enum TagsListItem {
    case SectionHeaderItem(SectionHeader)
    case TagItem(HypeMachineAPI.Tag)
    
    static func fromObject(object: AnyObject) -> TagsListItem? {
        if object is HypeMachineAPI.Tag {
            return TagsListItem.TagItem(object as! HypeMachineAPI.Tag)
        } else if object is SectionHeader {
            return TagsListItem.SectionHeaderItem(object as! SectionHeader)
        } else {
            return nil
        }
    }
}