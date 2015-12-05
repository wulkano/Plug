//
//  TracksRequests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Requests {
    public struct Tracks {
        public static func index(optionalParams optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Tracks.Index(optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(result)
            }
        }
        
        public static func show(id id: String, callback: (Result<Track>)->Void) {
            Alamofire.request(Router.Tracks.Show(id)).validate().responseObject {
                (request, response, result: Result<Track>) in
                callback(result)
            }
        }
        
        public static func popular(optionalParams optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Tracks.Popular(optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(result)
            }
        }
    }
}