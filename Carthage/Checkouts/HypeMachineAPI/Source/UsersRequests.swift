//
//  UsersRequests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Requests {
    public struct Users {
        public static func show(username username: String, callback: (Result<User>)->Void) {
            Alamofire.request(Router.Users.Show(username)).validate().responseObject { (request, response, result: Result<User>) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
        
        public static func showFavorites(username username: String, optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Users.ShowFavorites(username, optionalParams)).validate().responseCollection { (request, response, result: Result<[Track]>) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
        
        public static func showFriends(username username: String, optionalParams: [String: AnyObject]?, callback: (Result<[User]>)->Void) {
            Alamofire.request(Router.Users.ShowFriends(username, optionalParams)).validate().responseCollection { (request, response, result: Result<[User]>) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
    }
}