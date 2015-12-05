//
//  BlogsRouter.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Router {
    public enum Blogs: URLRequestConvertible {
        
        case Index([String: AnyObject]?)
        case Show(Int)
        case ShowTracks(Int, [String: AnyObject]?)
        
        var method: Alamofire.Method {
            switch self {
            case .Index:
                return .GET
            case .Show:
                return .GET
            case .ShowTracks:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Index:
                return "/blogs"
            case .Show(let id):
                return "/blogs/\(id)"
            case .ShowTracks(let id, _):
                return "/blogs/\(id)/tracks"
            }
        }
        
        var params: [String: AnyObject]? {
            switch self {
            case .Index(let optionalParams):
                return optionalParams
            case .Show:
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