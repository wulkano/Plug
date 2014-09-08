//
//  HypeMachineAPI.swift
//  Plug
//
//  Created by Alex Marchant on 7/5/14.
//  Copyright (c) 2014 Alex Marchant. All rights reserved.
//

import Foundation

var apiBase = "https://api.hypem.com/v2"

struct HypeMachineAPI  {
 
    private static func deviceId() -> String {
        //        TODO fix this
        //        let username = username()
        //        return SSKeychain.passwordForService("Plug", account: username!)
        return "d7ee8670b0d5d73"
    }
    
    struct Tracks {
        private static func getTracks(url: String, page: Int, count: Int, parameters: [NSObject: AnyObject]?, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            var fullParameters = parameters ?? [NSObject: AnyObject]()
            fullParameters["page"] = "\(page)"
            fullParameters["count"] = "\(count)"
            fullParameters["hm_token"] = Authentication.GetToken()!
            HTTP.GetJSON(url,
                parameters: fullParameters,
                success: { operation, responseObject in
                    let tracks = self.parseTracksFromResponse(responseObject)
                    success(tracks: tracks, lastPage: false)
                }, failure: { operation, error in
                    if self.pageNotFound(operation) {
                        success(tracks: [], lastPage: true)
                    } else {
                        failure(error: error)
                    }
            })
        }
        
        private static func parseTracksFromResponse(responseObject: AnyObject) -> [Track] {
            let responseArray = responseObject as NSArray
            var tracks = [Track]()
            for trackObject: AnyObject in responseArray {
                let trackDictionary = trackObject as NSDictionary
                let track = Track(JSON: trackDictionary)
                tracks.append(track)
            }
            return tracks
        }
        
        private static func pageNotFound(operation: AFHTTPRequestOperation) -> Bool {
            return operation.response.statusCode == 404
        }
        
        static func Popular(subType: PopularPlaylistSubType, page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/popular"
            let params = ["mode": subType.toRaw()]
            getTracks(url, page: page, count: count, parameters: params, success: success, failure: failure)
        }
        
        static func Favorites(page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/me/favorites"
            getTracks(url, page: page, count: count, parameters: nil, success: success, failure: failure)
        }
        
        static func Latest(page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tracks"
            getTracks(url, page: page, count: count, parameters: nil, success: success, failure: failure)
        }
        
        static func Feed(subType: FeedPlaylistSubType, page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/me/feed"
            let params = ["mode": subType.toRaw()]
            getTracks(url, page: page, count: count, parameters: params, success: success, failure: failure)
        }
        
        static func Search(searchKeywords: String, subType: SearchPlaylistSubType, page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tracks"
            let escapedSearchKeywords = searchKeywords.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            let params = ["sort": subType.toRaw(), "q": escapedSearchKeywords]
            getTracks(url, page: page, count: count, parameters: params, success: success, failure: failure)
        }
        
        static func Artist(artistName: String, page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let escapedArtistName = artistName.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
            let url = apiBase + "/artists/\(escapedArtistName)/tracks"
            getTracks(url, page: page, count: count, parameters: nil, success: success, failure: failure)
        }
        
        static func BlogTracks(blog: Blog, page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/blogs/\(blog.id)/tracks"
            getTracks(url, page: page, count: count, parameters: nil, success: success, failure: failure)
        }
        
        static func GenreTracks(genre: Genre, page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let escapedGenreName = genre.name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
            let url = apiBase + "/tags/\(escapedGenreName)/tracks"
            getTracks(url, page: page, count: count, parameters: nil, success: success, failure: failure)
        }
        
        static func FriendTracks(friend: Friend, page: Int, count: Int, success: (tracks: [Track], lastPage: Bool)->(), failure: (error: NSError)->()) {
            let escapedUsername = friend.username.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
            let url = apiBase + "/users/\(escapedUsername)/favorites"
            getTracks(url, page: page, count: count, parameters: nil, success: success, failure: failure)
        }
        
        static func ToggleLoved(track: Track, success: (loved: Bool)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/me/favorites?hm_token=\(Authentication.GetToken()!)"
            let params = ["type": "item", "val": track.id]
            HTTP.PostHTML(url, parameters: params,
                success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let responseData = responseObject as NSData
                    var html = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                    if html == "1" {
                        success(loved: true)
                    } else if html == "0" {
                        success(loved: false)
                    } else {
                        let error = NSError(domain: PlugErrorDomain, code: 1, userInfo: [NSLocalizedDescriptionKey: "Unexpected api response"])
                        failure(error: error)
                    }
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure(error: error)
            })
        }
        
        static func Thumb(track: Track, preferedSize: Track.ImageSize, success: (image: NSImage)->(), failure: (error: NSError)->()) {
            var url = track.thumbURLWithPreferedSize(preferedSize).absoluteString!
            HTTP.GetImage(url, parameters: nil,
                success: {operation, responseObject in
                    let image = responseObject as NSImage
                    success(image: image)
                }, failure: {operation, error in
                    failure(error: error)
            })
        }
    }
    
    struct Playlists {
        static var trackCount: Int = 20
        
        static func Popular(subType: PopularPlaylistSubType, success: (playlist: PopularPlaylist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Popular(subType,
                page: 1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = PopularPlaylist(tracks: tracks, subType: subType)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func Favorites(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Favorites(1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = FavoritesPlaylist(tracks: tracks)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func Latest(success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Latest(1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = LatestPlaylist(tracks: tracks)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func Feed(subType: FeedPlaylistSubType, success: (playlist: FeedPlaylist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Feed(subType,
                page: 1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = FeedPlaylist(tracks: tracks, subType: subType)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func Search(searchKeywords: String, subType: SearchPlaylistSubType, success: (playlist: SearchPlaylist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Search(searchKeywords,
                subType: subType,
                page: 1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = SearchPlaylist(tracks: tracks,
                        subType: subType,
                        searchKeywords: searchKeywords
                    )
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func Artist(artistName: String, success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.Artist(artistName,
                page: 1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = Playlist(tracks: tracks, type: .Artist)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func BlogPlaylist(blog: Blog, success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.BlogTracks(blog,
                page: 1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = Playlist(tracks: tracks, type: .Blog)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func GenrePlaylist(genre: Genre, success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.GenreTracks(genre,
                page: 1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = Playlist(tracks: tracks, type: .Genre)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
        
        static func FriendPlaylist(friend: Friend, success: (playlist: Playlist)->(), failure: (error: NSError)->()) {
            HypeMachineAPI.Tracks.FriendTracks(friend,
                page: 1,
                count: trackCount,
                success: { tracks, lastPage in
                    let playlist = Playlist(tracks: tracks, type: .Friend)
                    success(playlist: playlist)
                },
                failure: failure
            )
        }
    }
    
    struct Blogs {
        static func AllBlogs(success: (blogs: [Blog])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/blogs"
            let params = ["hm_token": Authentication.GetToken()!]
            HTTP.GetJSON(url, parameters: params,
                success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let responseArray = responseObject as NSArray
                    var blogs = [Blog]()
                    for blogObject: AnyObject in responseArray {
                        let blogDictionary = blogObject as NSDictionary
                        blogs.append(Blog(JSON: blogDictionary))
                    }
                    success(blogs: blogs)
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure(error: error)
            })
        }
        
        static func SingleBlog(blogID: Int, success: (blog: Blog)->(), failure: (error: NSError)->()) {
            let url = apiBase + "/blogs/\(blogID)"
            let params = ["hm_token": Authentication.GetToken()!]
            HTTP.GetJSON(url, parameters: params,
                success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let blogDictionary = responseObject as NSDictionary
                    let blog = Blog(JSON: blogDictionary)
                    success(blog: blog)
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure(error: error)
            })
        }
        
        static func Image(blog: Blog, size: Blog.ImageSize, success: (image: NSImage)->(), failure: (error: NSError)->()) {
            var url = blog.imageURLForSize(size).absoluteString!
            HTTP.GetImage(url, parameters: nil,
                success: {operation, responseObject in
                    let image = responseObject as NSImage
                    success(image: image)
                }, failure: {operation, error in
                    failure(error: error)
            })
        }
    }
    
    struct Genres {
        static func AllGenres(success: (genres: [Genre])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/tags"
            let params = ["hm_token": Authentication.GetToken()!]
            HTTP.GetJSON(url, parameters: params,
                success: {(operation: AFHTTPRequestOperation!, responseObject: AnyObject!) in
                    let responseArray = responseObject as NSArray
                    var genres = [Genre]()
                    for genreObject: AnyObject in responseArray {
                        let genreDictionary = genreObject as NSDictionary
                        genres.append(Genre(JSON: genreDictionary))
                    }
                    success(genres: genres)
                }, failure: {
                    (operation: AFHTTPRequestOperation!, error: NSError!) in
                    failure(error: error)
            })
        }
    }

    struct Friends {
        static func AllFriends(success: (friends: [Friend])->(), failure: (error: NSError)->()) {
            let url = apiBase + "/users/" + Authentication.GetUsername()! + "/friends"
            let params = ["hm_token": Authentication.GetToken()!]
            HTTP.GetJSON(url, parameters: params,
                success: {operation, responseObject in
                    let responseArray = responseObject as NSArray
                    var friends = [Friend]()
                    for friendObject: AnyObject in responseArray {
                        let friendDictionary = friendObject as NSDictionary
                        friends.append(Friend(JSON: friendDictionary))
                    }
                    success(friends: friends)
                }, failure: {operation, error in
                    failure(error: error)
            })
        }
        
        static func SingleFriend(username: String, success: (friend: Friend)->(), failure: (error: NSError)->()) {
            let escapedUsername = username.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLPathAllowedCharacterSet())!
            let url = apiBase + "/users/\(escapedUsername)"
            let params = ["hm_token": Authentication.GetToken()!]
            HTTP.GetJSON(url, parameters: params,
                success: {operation, responseObject in
                    let friendDictionary = responseObject as NSDictionary
                    let friend = Friend(JSON: friendDictionary)
                    success(friend: friend)
                }, failure: {operation, error in
                    failure(error: error)
            })
        }
        
        static func Avatar(friend: Friend, success: (image: NSImage)->(), failure: (error: NSError)->()) {
            var url = friend.avatarURL!.absoluteString!
            HTTP.GetImage(url, parameters: nil,
                success: {operation, responseObject in
                    let image = responseObject as NSImage
                    success(image: image)
                }, failure: {operation, error in
                    failure(error: error)
            })
        }
    }
    
    static func GetToken(username: String, password: String, success: (token: String)->(), failure: (error: NSError)->()) {
        let url = apiBase + "/get_token"
        let params = ["username": username, "password": password, "device_id": deviceId()]
        HTTP.PostJSON(url, parameters: params,
            success: {operation, responseObject in
                let responseDictionary = responseObject as NSDictionary
                let token = responseDictionary["hm_token"] as String
                success(token: token)
            }, failure: {operation, error in
                if let errorMessage = self._tryToParseHypeMachineErrorMessage(error) {
                    failure(error: NSError(domain: PlugErrorDomain, code: 2, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                } else {
                    failure(error: error)
                }
        })
    }
    
    static func HeatMapFor(track: Track, success: (heatMap: HeatMap)->(), failure: (error: NSError)->()) {
        let url = "http://hypem.com/inc/serve_track_graph.php"
        let params = ["id": track.id]
        HTTP.GetHTML(url, parameters: params,
            success: {operation, responseObject in
                let responseData = responseObject as NSData
                var html = NSString(data: responseData, encoding: NSUTF8StringEncoding)
                var error: NSError?
                let heatMap = HeatMap(track: track, html: html, error: &error)
                if error != nil {
                    failure(error: error!)
                } else {
                    success(heatMap: heatMap)
                }
            }, failure: {operation, error in
                failure(error: error)
        })
    }
    
    private static func _tryToParseHypeMachineErrorMessage(error: NSError) -> String? {
        var errorResponse = error.userInfo![JSONResponseSerializerWithDataKey] as? NSString
        if errorResponse == nil { return nil }
        
        var data = errorResponse!.dataUsingEncoding(NSUTF8StringEncoding)
        if data == nil { return nil }
        if data!.length <= 0 { return nil }
        
        var serializationError: NSError?
        var responseObject = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &serializationError) as? NSDictionary
        if serializationError != nil { return nil }
        if responseObject == nil { return nil }
        if responseObject!["status"] as? NSString != "error" { return nil }
        
        return responseObject!["error_msg"] as? NSString
    }
}