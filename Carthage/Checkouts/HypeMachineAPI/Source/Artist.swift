//
//  Artist.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

public final class Artist: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable {
    public let name: String
    public let thumbURL: NSURL?
    public let cnt: Int?
    public let rank: Int?
    
    override public var description: String {
        return "<Artist - name: \(name)>"
    }
    
    public required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        guard
            let name = representation["artist"] as? String
        else {
            // Shouldn't need this, probably a bug, delete later
            self.name = ""
            self.thumbURL = nil
            self.cnt = nil
            self.rank = nil
            super.init()
            // Shouldn't need this, probably a bug, delete later
            return nil
        }
        
        func urlForJSONKey(key: String) -> NSURL? {
            guard let urlString = representation[key] as? String else {
                return nil
            }
            return NSURL(string: urlString)
        }
        
        self.name = name
        self.thumbURL = urlForJSONKey("thumb_url_artist")
        self.cnt = representation["cnt"] as? Int
        self.rank = representation["rank"] as? Int
        
        super.init()
    }
    
    public class func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Artist] {
        var artists = [Artist]()
        
        if let collectionJSON = representation as? [NSDictionary] {
            for recordJSON in collectionJSON {
                if let artist = Artist(response: response, representation: recordJSON) {
                    artists.append(artist)
                }
            }
        }
        
        return artists
    }
}
