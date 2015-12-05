//
//  UserTests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa
import XCTest
import HypeMachineAPI

class UserTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func testBuildArtist() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("User", ofType: "json")
        let user = HypeMachineAPI.User(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(user)
        XCTAssert(user!.username == "alex_marchant")
    }
    
    func testBuildArtistCollection() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("Users", ofType: "json")
        let users = HypeMachineAPI.User.collection(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(users)
        XCTAssert(users.count == 3)
    }
}
