//
//  SimpleGoogleAnalyticsTests.swift
//  SimpleGoogleAnalyticsTests
//
//  Created by Alex Marchant on 5/10/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Foundation
import XCTest
import SimpleGoogleAnalytics

class SimpleGoogleAnalyticsTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSetup() {
        let tracker = SimpleGoogleAnalytics.Manager(trackingID: "UA-11111111-1", userID: nil)
        XCTAssertNotNil(tracker)
    }
    
    func testTrackPageview() {
        // Just running to test for exceptions
        let tracker = SimpleGoogleAnalytics.Manager(trackingID: "UA-11111111-1", userID: nil)
        tracker.trackPageview("Test")
        XCTAssertNotNil(tracker)
    }
    
    func testTrackEvent() {
        // Just running to test for exceptions
        let tracker = SimpleGoogleAnalytics.Manager(trackingID: "UA-11111111-1", userID: nil)
        tracker.trackEvent(category: "Button", action: "Click", label: "Test", value: nil)
        XCTAssertNotNil(tracker)
    }
}
