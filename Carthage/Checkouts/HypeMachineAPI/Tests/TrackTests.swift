//
//  TrackTests.swift
//  HypeMachineAPI
//
//  Created by Alex Marchant on 5/11/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa
import XCTest
import HypeMachineAPI

class TrackTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    override func tearDown() {
        super.tearDown()
    }

    func testBuildTrack() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("Track", ofType: "json")
        let track = HypeMachineAPI.Track(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(track)
        XCTAssert(track!.id == "2b8fz")
    }
    
    func testBuildTrackCollection() {
        let json: AnyObject = Helpers.loadJSONFixtureFile("Tracks", ofType: "json")
        let tracks = HypeMachineAPI.Track.collection(response: NSHTTPURLResponse(), representation: json)
        
        XCTAssertNotNil(tracks)
        XCTAssert(tracks.count == 3)
    }
}
