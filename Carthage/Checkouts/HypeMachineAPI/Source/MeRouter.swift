//
//  MeRouter.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Router {
    public enum Me: URLRequestConvertible {
        
        case Favorites([String: AnyObject]?)
        case ToggleTrackFavorite(String, [String: AnyObject]?)
        case ToggleBlogFavorite(Int, [String: AnyObject]?)
        case ToggleUserFavorite(String, [String: AnyObject]?)
        case PlaylistNames
        case ShowPlaylist(Int, [String: AnyObject]?)
        case PostHistory(String, Int, [String: AnyObject]?)
        case Friends([String: AnyObject]?)
        case Feed([String: AnyObject]?)
        
        var method: Alamofire.Method {
            switch self {
            case .Favorites:
                return .GET
            case .ToggleTrackFavorite:
                return .POST
            case .ToggleBlogFavorite:
                return .POST
            case .ToggleUserFavorite:
                return .POST
            case PlaylistNames:
                return .GET
            case ShowPlaylist:
                return .GET
            case PostHistory:
                return .POST
            case .Friends:
                return .GET
            case .Feed:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .Favorites:
                return "/me/favorites"
            case .ToggleTrackFavorite:
                return "/me/favorites"
            case .ToggleBlogFavorite:
                return "/me/favorites"
            case .ToggleUserFavorite:
                return "/me/favorites"
            case PlaylistNames:
                return "/me/playlist_names"
            case ShowPlaylist(let id, _):
                return "/me/playlists/\(id)"
            case PostHistory:
                return "/me/history"
            case .Friends:
                return "/me/friends"
            case .Feed:
                return "/me/feed"
            }
        }
        
        var params: [String: AnyObject]? {
            switch self {
            case .Favorites(let optionalParams):
                return optionalParams
            case .ToggleTrackFavorite(let id, let optionalParams):
                return ["val": id, "type": "item"].merge(optionalParams)
            case .ToggleBlogFavorite(let id, let optionalParams):
                return ["val": id, "type": "site"].merge(optionalParams)
            case .ToggleUserFavorite(let id, let optionalParams):
                return ["val": id, "type": "user"].merge(optionalParams)
            case PlaylistNames:
                return nil
            case ShowPlaylist(_, let optionalParams):
                return optionalParams
            case PostHistory(let id, let position, let optionalParams):
                return ["type": "listen", "itemid": id, "pos": position].merge(optionalParams)
            case .Friends(let optionalParams):
                return optionalParams
            case .Feed(let optionalParams):
                return optionalParams
            }
        }
        
        public var URLRequest: NSMutableURLRequest {
            return Router.URLRequest(method: method, path: path, params: params)
        }
    }
}