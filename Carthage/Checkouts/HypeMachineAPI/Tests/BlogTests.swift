//
//  BlogTests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa
import XCTest
import HypeMachineAPI

class BlogTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func testBuildBlog() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("Blog", ofType: "json")
        let blog = HypeMachineAPI.Blog(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(blog)
        XCTAssert(blog!.id == 16684)
    }
    
    func testBuildBlogCollection() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("Blogs", ofType: "json")
        let blogs = HypeMachineAPI.Blog.collection(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(blogs)
        XCTAssert(blogs.count == 3)
        
        XCTAssert(blogs[0].featured == true)
        XCTAssert(blogs[0].following == true)
        
        XCTAssert(blogs[1].featured == false)
        XCTAssert(blogs[1].following == false)
    }
}
