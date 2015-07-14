//
//  UsersDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class UsersDataSource: SearchableDataSource {
    
    func filterUsersMatchingSearchKeywords(users: [HypeMachineAPI.User]) -> [HypeMachineAPI.User] {
        return users.filter { user in
            if user.fullName != nil {
                return (user.username =~ self.searchKeywords!) || (user.fullName! =~ self.searchKeywords!)
            } else {
                return user.username =~ self.searchKeywords!
            }
        }
    }
    
    func sortUsers(users: [HypeMachineAPI.User]) -> [HypeMachineAPI.User] {
        return users.sorted { $0.username.lowercaseString < $1.username.lowercaseString }
    }
    
    // MARK: SearchableDataSource
    
    override func filterObjectsMatchingSearchKeywords(objects: [AnyObject]) -> [AnyObject] {
        let users = objects as! [HypeMachineAPI.User]
        return filterUsersMatchingSearchKeywords(users)
    }
    
    // MARK: HypeMachineDataSource
    
    override var singlePage: Bool {
        return true
    }
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Me.friends(optionalParams: nil) { (friends, error) in
            self.nextPageObjectsReceived(friends, error: error)
        }
    }
    
    override func appendTableContents(contents: [AnyObject]) {
        let users = contents as! [HypeMachineAPI.User]
        let sortedUsers = sortUsers(users)
        super.appendTableContents(sortedUsers)
    }
}