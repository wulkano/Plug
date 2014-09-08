//
//  File.swift
//  Plug
//
//  Created by Alex Marchant on 9/7/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

struct HTTP {
    static func GetJSON(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = PlugJSONResponseSerializer()
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func GetHTML(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func GetImage(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFImageResponseSerializer()
        // Need this to load images from S3
        let contentTypesSet = manager.responseSerializer.acceptableContentTypes;
        manager.responseSerializer.acceptableContentTypes = contentTypesSet.setByAddingObject("application/octet-stream")
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func PostJSON(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = PlugJSONResponseSerializer()
        manager.POST(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func PostHTML(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.POST(url, parameters: parameters, success: success, failure: failure)
    }
}