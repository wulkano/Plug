//
//  Fixtures.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation

class Helpers {
    class func loadJSONFixtureFile(name: String, ofType ext: String) -> AnyObject {
        let path = NSBundle(forClass: Helpers().dynamicType).pathForResource(name, ofType: ext)!
        let jsonData = try! NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe)
        return try! NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
    }
}