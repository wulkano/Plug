//
//  TagsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class TagsDataSource: MainContentDataSource {
    
    override func loadInitialValues() {
        HypeMachineAPI.Requests.Tags.index {
            (tags: [Tag]?, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                Logger.LogError(error!)
                self.viewController.requestInitialValuesFinished()
                return
            }
            
            self.generateTableContents(tags!)
            self.viewController.tableView.reloadData()
            self.viewController.requestInitialValuesFinished()
        }
    }
    
    func generateTableContents(tags: [HypeMachineAPI.Tag]) {
        standardTableContents.append(SectionHeader(title: "The Basics"))
        var priorityTags = tags.filter { $0.priority == true }
        priorityTags = priorityTags.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        standardTableContents += priorityTags as [AnyObject]
        
        standardTableContents.append(SectionHeader(title: "Everything"))
        var sortedTags = tags.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
        standardTableContents += sortedTags as [AnyObject]
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            var filteredTags = allTags().filter { $0.name =~ keywords }
            var sortedTags = filteredTags.sorted { $0.name.lowercaseString < $1.name.lowercaseString }
            filteredTableContents = filteredTags
        }
        viewController.tableView.reloadData()
    }
    
    func allTags() -> [HypeMachineAPI.Tag] {
        var results: [HypeMachineAPI.Tag] = []
        for object in standardTableContents {
            if object is HypeMachineAPI.Tag {
                let tag = object as! HypeMachineAPI.Tag
                if find(results, tag) == nil {
                    results.append(tag)
                }
            }
        }
        return results
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