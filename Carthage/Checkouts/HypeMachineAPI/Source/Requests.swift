//
//  Requests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation

public struct Requests {}

extension Requests {
    enum Errors: ErrorType {
        case CantParseResponse
    }
}

public func parseHypeMachineErrorFromResult<T>(result: Result<T>) -> Result<T> {
    guard
        case .Failure(let data, _) = result,
        let apiError = parseAPIErrorFromData(data)
    else {
        return result
    }
    return Result<T>.Failure(data, apiError)
}

public func parseAPIErrorFromData(data: NSData?) -> NSError? {
    guard
        let data = data,
        let object = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments),
        let JSONDictionary = object as? NSDictionary,
        let errorMessage = JSONDictionary["error_msg"] as? String
    else {
            return nil
    }
    
    let userInfo: [NSObject: AnyObject] = [NSLocalizedDescriptionKey: errorMessage]
    
    switch errorMessage {
    case "Must provide valid hm_token":
        return NSError(domain: ErrorDomain, code: ErrorCodes.InvalidHMToken.rawValue, userInfo: userInfo)
    case "Wrong password":
        return NSError(domain: ErrorDomain, code: ErrorCodes.WrongPassword.rawValue, userInfo: userInfo)
    case "Wrong username":
        return NSError(domain: ErrorDomain, code: ErrorCodes.WrongUsername.rawValue, userInfo: userInfo)
    default:
        return NSError(domain: ErrorDomain, code: ErrorCodes.UnknownError.rawValue, userInfo: userInfo)
    }
}

let ErrorDomain = "HypeMachineAPI.ErrorDomain"

public enum ErrorCodes: Int {
    case UnknownError
    case WrongPassword
    case WrongUsername
    case InvalidHMToken
}