//
//  Router.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/10/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

public struct Router {
    static let baseURLString = "https://api.hypem.com/v2"
    
    static func URLRequest(method method: Alamofire.Method, path: String, params: [String: AnyObject]?) -> NSMutableURLRequest {
        
        // Probably a bug in the hype machine API, but hm_token must be part of the path, can't be form encoded
        var urlString = baseURLString + path
        if hmToken != nil {
            urlString += "?hm_token=\(hmToken!)"
        }
        let URL = NSURL(string: urlString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if userAgent != nil {
            mutableURLRequest.addValue(userAgent!, forHTTPHeaderField: "User-Agent")
        }
        
        var mergedParams: [String: AnyObject]?
        mergedParams = addApiKeyParam(params)
        
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: mergedParams).0
    }
    
    static func addApiKeyParam(params: [String: AnyObject]?) -> [String: AnyObject]? {
        if apiKey == nil { return params }
        return ["key": apiKey!].merge(params)
    }
}