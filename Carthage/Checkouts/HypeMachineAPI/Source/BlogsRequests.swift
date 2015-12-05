//
//  BlogsRequests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Requests {
    public struct Blogs {
        public static func index(optionalParams optionalParams: [String: AnyObject]?, callback: (Result<[Blog]>)->Void) {
            Alamofire.request(Router.Blogs.Index(optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Blog]>) in
                callback(result)
            }
        }
        
        public static func show(id id: Int, callback: (Result<Blog>)->Void) {
            Alamofire.request(Router.Blogs.Show(id)).validate().responseObject {
                (request, response, result: Result<Blog>) in
                callback(result)
            }
        }
        
        public static func showTracks(id id: Int, optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Blogs.ShowTracks(id, optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(result)
            }
        }
    }
}