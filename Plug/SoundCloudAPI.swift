//
//  SoundCloudAPI.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

let ClientID = "2c3c67194673f9968b7c8b5f2b50d486"

struct SoundCloudAPI {
    struct Tracks {
        static func Permalink(trackID: String, success: (trackURL: NSURL)->(), failure: (error: NSError)->()) {
            let url = "http://api.soundcloud.com/tracks/\(trackID).json"
            let parameters: [NSObject: AnyObject] = ["client_id": ClientID]
            HTTP.GetJSON(url,
                parameters: parameters,
                success: { operation, responseObject in
                    let responseDictionary = responseObject as! NSDictionary
                    if let permalink = responseDictionary["permalink_url"] as? String {
                        let trackURL = NSURL(string: permalink)!
                        success(trackURL: trackURL)
                    } else {
                        let error = NSError(domain: PlugErrorDomain, code: 3, userInfo: [NSLocalizedDescriptionKey: "No permalink found in response."])
                        failure(error: error)
                    }
                }, failure: { operation, error in
                    failure(error: error)
            })
        }
    }
}
