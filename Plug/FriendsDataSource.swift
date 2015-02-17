//
//  FriendsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class FriendsDataSource: MainContentDataSource {
    
    override func loadInitialValues() {
        HypeMachineAPI.Friends.AllFriends(
            {friends in
                self.generateTableContents(friends)
                self.viewController.tableView.reloadData()
                self.viewController.requestInitialValuesFinished()
            }, failure: {error in
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error])
                Logger.LogError(error)
                self.viewController.requestInitialValuesFinished()
        })
    }
    
    func generateTableContents(friends: [Friend]) {
        standardTableContents = friends.sorted { $0.username.lowercaseString < $1.username.lowercaseString }
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            filteredTableContents = standardTableContents.filter {
                let friend = $0 as! Friend
                return (friend.username =~ keywords) || (friend.fullName =~ keywords)
            }
        }
        viewController.tableView.reloadData()
    }
}