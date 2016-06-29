//
//  Tag.swift
//  Plug
//
//  Created by Alex Marchant on 8/1/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

public final class Tag: NSObject, ResponseObjectSerializable, ResponseCollectionSerializable {
    public let name: String
    public let priority: Bool
    
    override public var description: String {
        return "<Tag - name: \(name), priority: \(priority)>"
    }
    
    public required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        guard
            let name = representation["tag_name"] as? String
        else {
            return nil
        }
        
        self.name = name
        self.priority = representation["priority"] as? Bool ?? false
        
        super.init()
    }
    
    public class func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Tag] {
        var tags = [Tag]()
        
        if let collectionJSON = representation as? [NSDictionary] {
            for recordJSON in collectionJSON {
                if let tag = Tag(response: response, representation: recordJSON) {
                    tags.append(tag)
                }
            }
        }
        
        return tags
    }
}