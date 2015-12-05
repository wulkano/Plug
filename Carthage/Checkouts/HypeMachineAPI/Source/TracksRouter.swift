//
//  TracksRouter.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/10/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Router {
    public enum Tracks: URLRequestConvertible {
        
        case Index([String: AnyObject]?)
        case Show(String)
        case Popular([String: AnyObject]?)
        
        var method: Alamofire.Method {
            switch self {
            case .Index:
                return .GET
            case .Show:
                return .GET
            case .Popular:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Index:
                return "/tracks"
            case .Show(let id):
                return "/tracks/\(id)"
            case .Popular:
                return "/popular"
            }
        }
        
        var params: [String: AnyObject]? {
            switch self {
            case .Index(let optionalParams):
                return optionalParams
            case .Show:
                return nil
            case .Popular(let optionalParams):
                return optionalParams
            }
        }
        
        public var URLRequest: NSMutableURLRequest {
            return Router.URLRequest(method: method, path: path, params: params)
        }
    }
}