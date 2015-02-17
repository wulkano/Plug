//
//  PlugJSONResponseSerializer.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlugJSONResponseSerializer: AFJSONResponseSerializer {
    
    override func responseObjectForResponse(response: NSURLResponse!, data: NSData!, error: NSErrorPointer) -> AnyObject! {
        
        if !validateResponse(response as! NSHTTPURLResponse, data: data, error: error) {
            if error.memory != nil {
                var oldError = error.memory!
                var userInfo = oldError.userInfo!
                userInfo[JSONResponseSerializerWithDataKey] = NSString(data: data, encoding: NSUTF8StringEncoding)
                var newError = NSError(domain: oldError.domain, code: oldError.code, userInfo: userInfo)
                error.memory = newError
            }
            return nil
        }
        
        return super.responseObjectForResponse(response, data: data, error: error)
    }
}
