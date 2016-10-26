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
        static func permalink(_ trackId: String, callback: (Result<NSURL>)->Void) {
            let url = "https://api.soundcloud.com/tracks/\(trackId).json"
            
            Alamofire.request(.GET, url, parameters: ["client_id": ClientID]).validate().responseJSON { (_, _, result) in
                switch result {
                case .Success(let JSON):
                    guard
                        let permalinkString = JSON["permalink_url"] as? String,
                        let permalinkURL = NSURL(string: permalinkString)
                    else {
                        callback(Result.Failure(nil, SoundCloudAPI.Errors.CantParseResponse))
                        break
                    }
                    callback(Result.Success(permalinkURL))
                case .Failure(let data, let error):
                    callback(Result.Failure(data, error))
                }
            }
        }
    }
    
    enum Errors: Error {
        case cantParseResponse
    }
}
