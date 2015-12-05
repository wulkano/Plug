//
//  MiscRequests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Requests {
    public struct Misc {
        public static func getToken(usernameOrEmail usernameOrEmail: String, password: String, callback: (Result<UsernameAndToken>)->Void) {
            Alamofire.request(Router.Misc.GetToken(usernameOrEmail, password)).validate().responseJSON { (req, resp, result) in
                switch result {
                case .Success(let JSON):
                    guard
                        let username = JSON["username"] as? String,
                        let token = JSON["hm_token"] as? String
                        else {
                            callback(Result.Failure(nil, Requests.Errors.CantParseResponse))
                            break
                    }
                    callback(Result.Success(UsernameAndToken(username: username, token: token)))
                case .Failure(let data, let error):
                    callback(parseHypeMachineErrorFromResult(Result.Failure(data, error)))
                }
            }
        }
        
        public struct UsernameAndToken {
            public let username: String
            public let token: String
            
            init(username: String, token: String) {
                self.username = username
                self.token = token
            }
        }
    }
}