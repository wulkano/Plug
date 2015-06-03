//
//  SoundCloudAPI.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation
import Alamofire

let ClientID = "2c3c67194673f9968b7c8b5f2b50d486"

struct SoundCloudAPI {
    struct Tracks {
        
        static func permalink(trackId: String, callback: (permalink: NSURL?, error: NSError?)->Void) {
            let url = "http://api.soundcloud.com/tracks/\(trackId).json"
            
            Alamofire.request(.GET, url, parameters: ["client_id": ClientID]).validate().responseJSON {
                (_, _, JSON, error) in
                var permalink: NSURL?
                
                if error == nil {
                    if let permalinkString = (JSON?.valueForKeyPath("permalink_url") as? String) {
                        permalink = NSURL(string: permalinkString)
                    }
                }
                
                callback(permalink: permalink, error: error)
            }
        }
    }
}
