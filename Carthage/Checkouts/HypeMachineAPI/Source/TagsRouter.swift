//
//  TagsRouter.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Router {
    public enum Tags: URLRequestConvertible {
        
        case Index
        case ShowTracks(String, [String: AnyObject]?)
        
        var method: Alamofire.Method {
            switch self {
            case .Index:
                return .GET
            case .ShowTracks:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Index:
                return "/tags"
            case .ShowTracks(let name, _):
                let escapedName = name.stringByAddingPercentEncodingForURLQueryValue()!
                return "/tags/\(escapedName)/tracks"
            }
        }
        
        var params: [String: AnyObject]? {
            switch self {
            case .Index:
                return nil
            case .ShowTracks(_, let optionalParams):
                return optionalParams
            }
        }
        
        public var URLRequest: NSMutableURLRequest {
            return Router.URLRequest(method: method, path: path, params: params)
        }
    }
}