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
        if tags.count > 1 {
            return tags.sort { $0.name.lowercaseString < $1.name.lowercaseString }
        } else {
            return tags
        }
    }
    
    func groupTags(tags: [HypeMachineAPI.Tag]) -> [AnyObject] {
        var groupedTags: [AnyObject] = []
        
        groupedTags.append(SectionHeader(title: "The Basics"))
        var priorityTags = tags.filter { $0.priority == true }
        priorityTags = priorityTags.sort { $0.name.lowercaseString < $1.name.lowercaseString }
        groupedTags += priorityTags as [AnyObject]
        
        groupedTags.append(SectionHeader(title: "Everything"))
        let sortedTags = tags.sort { $0.name.lowercaseString < $1.name.lowercaseString }
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
            
            //Has keywords so filter tags using keywords
            let filteredResults = filterTagsMatchingSearchKeywords(sortedTags)
            //If results of filter are zero then try and make a new object using the keywords
            if (filteredResults.count == 0) {
                //Make a new tag using the search Keyword
                
                let tempTag = [
                    "tag_name": searchKeywords!,
                    "priority": false
                ]
                let url = NSHTTPURLResponse()
                let tag = Tag(response: url, representation: tempTag)!
                let array = [tag]
                appendTableContents(array)
                return array
            }
            
            return filteredResults
        }
    }
    
    // MARK: HypeMachineDataSource
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Tags.index { result in
            self.nextPageResultReceived(result)
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
        if let tag = object as? HypeMachineAPI.Tag {
            return TagsListItem.TagItem(tag)
        } else if let sectionHeader = object as? SectionHeader {
            return TagsListItem.SectionHeaderItem(sectionHeader)
        } else {
            return nil
        }
    }
}