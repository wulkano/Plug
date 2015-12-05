//
//  ArtistsRequests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Requests {
    public struct Artists {
        public static func index(optionalParams optionalParams: [String: AnyObject]?, callback: (Result<[Artist]>)->Void) {
            Alamofire.request(Router.Artists.Index(optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Artist]>) in
                callback(result)
            }
        }
        
        public static func show(name name: String, callback: (Result<Artist>)->Void) {
            Alamofire.request(Router.Artists.Show(name)).validate().responseObject {
                (request, response, result: Result<Artist>) in
                callback(result)
            }
        }
        
        public static func showTracks(name name: String, optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Artists.ShowTracks(name, optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(result)
            }
        }
    }
}