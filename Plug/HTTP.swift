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
        manager.responseSerializer = PlugJSONResponseSerializer(readingOptions: nil)
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func GetHTML(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func GetImage(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFImageResponseSerializer.sharedSerializer()
        // Need this to load images from S3
        var contentTypesSet = manager.responseSerializer.acceptableContentTypes as Set<NSObject>
        var newSet = Set<NSObject>()
        newSet.union(contentTypesSet)
        newSet.insert("application/octet-stream")
        manager.responseSerializer.acceptableContentTypes = newSet
        manager.GET(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func PostJSON(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = PlugJSONResponseSerializer(readingOptions: nil)
        manager.POST(url, parameters: parameters, success: success, failure: failure)
    }
    
    static func PostHTML(url: String, parameters: [NSObject: AnyObject]?, success: ((operation: AFHTTPRequestOperation!, responseObject: AnyObject!)->())?, failure: ((operation: AFHTTPRequestOperation!, error: NSError!)->())?) {
        var manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager(baseURL: nil)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.POST(url, parameters: parameters, success: success, failure: failure)
    }
}