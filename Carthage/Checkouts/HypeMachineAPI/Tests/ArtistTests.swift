//
//  ArtistTests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa
import XCTest
import HypeMachineAPI

class ArtistTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }
    
    func testBuildArtist() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("Artist", ofType: "json")
        let artist = HypeMachineAPI.Artist(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(artist)
        XCTAssert(artist!.name == "ducktails")
    }
    
    func testBuildArtistCollection() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("Artists", ofType: "json")
        let artists = HypeMachineAPI.Artist.collection(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(artists)
        XCTAssert(artists.count == 3)
    }
}