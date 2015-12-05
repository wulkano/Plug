//
//  TagsRequests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Requests {
    public struct Tags {
        public static func index(callback: (Result<[Tag]>)->Void) {
            Alamofire.request(Router.Tags.Index).validate().responseCollection {
                (request, response, result: Result<[Tag]>) in
                callback(result)
            }
        }
        
        public static func showTracks(name name: String, optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Tags.ShowTracks(name, optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(result)
            }
        }
    }
}