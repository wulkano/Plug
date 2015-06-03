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
    class func imageResponseSerializer() -> Serializer {
        return { request, response, data in
            if data == nil {
                return (nil, nil)
            }
            
            let image = NSImage(data: data!)
            
            return (image, nil)
        }
    }
    
    func responseImage(completionHandler: (NSURLRequest, NSHTTPURLResponse?, NSImage?, NSError?) -> Void) -> Self {
        return response(serializer: Request.imageResponseSerializer(), completionHandler: { (request, response, image, error) in
            completionHandler(request, response, image as? NSImage, error)
        })
    }
}