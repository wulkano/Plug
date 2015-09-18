//
//  Alamofire+responseImage.swift
//  Plug
//
//  Created by Alex Marchant on 5/14/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import Alamofire

extension Alamofire.Request {
    public static func ImageResponseSerializer() -> GenericResponseSerializer<NSImage> {
        return GenericResponseSerializer { request, response, data in
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
            }
            
            guard let image = NSImage(data: validData) else {
                let failureReason = "Image could not be serialized."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
            }
            
            return .Success(image)
        }
    }
    
    public func responseImage(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<NSImage>) -> Void) -> Self {
        return response(responseSerializer: Request.ImageResponseSerializer(), completionHandler: completionHandler)
    }
}