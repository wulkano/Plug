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
    
    func filterUsersMatchingSearchKeywords(_ users: [HypeMachineAPI.User]) -> [HypeMachineAPI.User] {
        return users.filter { user in
            if user.fullName != nil {
                return (user.username =~ self.searchKeywords!) || (user.fullName! =~ self.searchKeywords!)
            } else {
                return user.username =~ self.searchKeywords!
            }
        }
    }
    
    func sortUsers(_ users: [HypeMachineAPI.User]) -> [HypeMachineAPI.User] {
        return users.sort { $0.username.lowercaseString < $1.username.lowercaseString }
    }
    
    // MARK: SearchableDataSource
    
    override func filterObjectsMatchingSearchKeywords(_ objects: [AnyObject]) -> [AnyObject] {
        let users = objects as! [HypeMachineAPI.User]
        return filterUsersMatchingSearchKeywords(users)
    }
    
    // MARK: HypeMachineDataSource
    
    override var singlePage: Bool {
        return true
    }
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Me.friends(optionalParams: nil) { result in
            self.nextPageResultReceived(result)
        }
    }
    
    override func appendTableContents(_ contents: [AnyObject]) {
        let users = contents as! [HypeMachineAPI.User]
        let sortedUsers = sortUsers(users)
        super.appendTableContents(sortedUsers)
    }
}
