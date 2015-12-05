//
//  MeRequests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Requests {
    public struct Me {
        public static func favorites(optionalParams optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Me.Favorites(optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
        
        public static func toggleTrackFavorite(id id: String, optionalParams: [String: AnyObject]?, callback: (Result<Bool>)->Void) {
            Alamofire.request(Router.Me.ToggleTrackFavorite(id, optionalParams)).validate().responseString {
                (request, response, result) in
                callback(convertStringResultToBoolResult(parseHypeMachineErrorFromResult(result)))
            }
        }
        
        public static func toggleBlogFavorite(id id: Int, optionalParams: [String: AnyObject]?, callback: (Result<Bool>)->Void) {
            Alamofire.request(Router.Me.ToggleBlogFavorite(id, optionalParams)).validate().responseString {
                (request, response, result) in
                callback(convertStringResultToBoolResult(parseHypeMachineErrorFromResult(result)))
            }
        }
        
        public static func toggleUserFavorite(id id: String, optionalParams: [String: AnyObject]?, callback: (Result<Bool>)->Void) {
            Alamofire.request(Router.Me.ToggleUserFavorite(id, optionalParams)).validate().responseString {
                (request, response, result) in
                callback(convertStringResultToBoolResult(parseHypeMachineErrorFromResult(result)))
            }
        }
        
        public static func playlistNames(callback: (Result<[String]>)->Void) {
            Alamofire.request(Router.Me.PlaylistNames).validate().responseJSON {
                (request, response, result) in
                callback(convertJSONResultToStringArrayResult(parseHypeMachineErrorFromResult(result)))
            }
        }
        
        // Playlist id's are 1...3
        public static func showPlaylist(id id: Int, optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Me.ShowPlaylist(id, optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
        
        public static func postHistory(id id: String, position: Int, optionalParams: [String: AnyObject]?, callback: (Result<String>)->Void) {
            Alamofire.request(Router.Me.PostHistory(id, position, optionalParams)).validate().responseString {
                (request, response, result) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
        
        public static func friends(optionalParams optionalParams: [String: AnyObject]?, callback: (Result<[User]>)->Void) {
            Alamofire.request(Router.Me.Friends(optionalParams)).validate().responseCollection {
                (request, response, result: Result<[User]>) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
        
        public static func feed(optionalParams optionalParams: [String: AnyObject]?, callback: (Result<[Track]>)->Void) {
            Alamofire.request(Router.Me.Feed(optionalParams)).validate().responseCollection {
                (request, response, result: Result<[Track]>) in
                callback(parseHypeMachineErrorFromResult(result))
            }
        }
        
        private static func convertStringResultToBoolResult(result: Result<String>) -> Result<Bool> {
            switch result {
            case .Success(let string):
                guard string == "0" || string == "1" else {
                    return Result.Failure(nil, Requests.Errors.CantParseResponse)
                }
                let favorited = string == "1"
                return Result.Success(favorited)
            case .Failure(let data, let error):
                return Result.Failure(data, error)
            }
        }
        
        private static func convertJSONResultToStringArrayResult(result: Result<AnyObject>) -> Result<[String]> {
            switch result {
            case .Success(let JSON):
                guard let stringArray = JSON as? [String] else {
                    return Result.Failure(nil, Requests.Errors.CantParseResponse)
                }
                return Result.Success(stringArray)
            case .Failure(let data, let error):
                return Result.Failure(data, error)
            }
        }
    }
}