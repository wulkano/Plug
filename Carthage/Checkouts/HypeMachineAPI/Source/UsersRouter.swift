//
//  UsersRouter.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Router {
    public enum Users: URLRequestConvertible {
        
        case Show(String)
        case ShowFavorites(String, [String: AnyObject]?)
        case ShowFriends(String, [String: AnyObject]?)
        
        var method: Alamofire.Method {
            switch self {
            case .Show:
                return .GET
            case .ShowFavorites:
                return .GET
            case .ShowFriends:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Show(let username):
                let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
                return "/users/\(escapedUsername)"
            case .ShowFavorites(let username, _):
                let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
                return "/users/\(escapedUsername)/favorites"
            case .ShowFriends(let username, _):
                let escapedUsername = username.stringByAddingPercentEncodingForURLQueryValue()!
                return "/users/\(escapedUsername)/friends"
            }
        }
        
        var params: [String: AnyObject]? {
            switch self {
            case .Show:
                return nil
            case .ShowFavorites(_, let optionalParams):
                return optionalParams
            case .ShowFriends(_, let optionalParams):
                return optionalParams
            }
        }
        
        public var URLRequest: NSMutableURLRequest {
            return Router.URLRequest(method: method, path: path, params: params)
        }
    }
}