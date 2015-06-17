//
//  FriendsDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class FriendsDataSource: MainContentDataSource {
    
    override func loadInitialValues() {
        HypeMachineAPI.Requests.Me.friends(optionalParams: nil) {
            (friends: [HypeMachineAPI.User]?, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                println(error!)
                self.viewController.requestInitialValuesFinished()
                return
            }
            
            self.generateTableContents(friends!)
            self.viewController.tableView.reloadData()
            self.viewController.requestInitialValuesFinished()
        }
    }
    
    func generateTableContents(friends: [HypeMachineAPI.User]) {
        standardTableContents = friends.sorted { $0.username.lowercaseString < $1.username.lowercaseString }
    }
    
    func filterByKeywords(keywords: String) {
        if keywords == "" {
            filtering = false
        } else {
            filtering = true
            filteredTableContents = standardTableContents.filter {
                let friend = $0 as! HypeMachineAPI.User
                if friend.fullName != nil {
                    return (friend.username =~ keywords) || (friend.fullName! =~ keywords)
                } else {
                    return friend.username =~ keywords
                }
            }
        }
        viewController.tableView.reloadData()
    }
}