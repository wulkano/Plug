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
        return users.sorted { $0.username.lowercased() < $1.username.lowercased() }
    }
    
    // MARK: SearchableDataSource
    
    override func filterObjectsMatchingSearchKeywords(_ objects: [Any]) -> [Any] {
        let users = objects as! [HypeMachineAPI.User]
        return filterUsersMatchingSearchKeywords(users)
    }
    
    // MARK: HypeMachineDataSource
    
    override var singlePage: Bool {
        return true
    }
    
    override func requestNextPageObjects() {
        HypeMachineAPI.Requests.Me.friends { response in
            self.nextPageResponseReceived(response)
        }
    }
    
    override func appendTableContents(_ contents: [Any]) {
        let users = contents as! [HypeMachineAPI.User]
        let sortedUsers = sortUsers(users)
        super.appendTableContents(sortedUsers)
    }
}
