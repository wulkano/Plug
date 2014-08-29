//
//  TrackGraph.swift
//  Plug
//
//  Created by Alexander Marchant on 7/17/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HeatMap: NSObject {
    var track: Track
    var html: String
    var bigPoints: NSArray?
    var postPoints: NSArray?
    
    init(track: Track, html: String, error: NSErrorPointer) {
        self.track = track
        self.html = html

        super.init()
        
        let bigPointsString = parseBigPoints()
        let postPointsString = parsePostPoints()

        bigPoints = serializeString(bigPointsString)
        postPoints = serializeString(postPointsString)
    }
    
//    TODO search for most applicable data
//    TODO find a way to return errors if no data is available
//    TODO fix algorithm, graphs are too slicey
    func relativeLast24HourData() -> (start: Double, end: Double) {
//        TODO: this is erroring out for our of range reasons
        let highRange: Double = 30
        let data = last24HourData()
        var startPoint = data.start / highRange
        var endPoint = data.end / highRange
        if startPoint > 1 { startPoint = 1 }
        if startPoint < 0.3 { startPoint = 0.3 } // TODO: Find some kind of log scale instead of this crap
        if endPoint > 1 { endPoint = 1 }
        return (startPoint, endPoint)
    }
    
    func last24HourData() -> (start: Double, end: Double) {
        // TODO: cleanup this is ugly
        var startPointIndex: Int
        if bigPoints!.count < 26 {
            startPointIndex = 1
        } else {
            startPointIndex = bigPoints!.count - 26
        }
        let startPointDict = bigPoints!.objectAtIndex(startPointIndex) as NSDictionary
        var startPointVal: Double = 0
        if startPointDict["1"] is Int {
            startPointVal = Double(startPointDict["1"] as Int)
        } else if startPointDict["1"] is Double {
            startPointVal = startPointDict["1"] as Double
        }
        let endPointDict = bigPoints!.objectAtIndex(bigPoints!.count - 2) as NSDictionary
        let endPointVal = endPointDict["1"] as Double
        return (startPointVal, endPointVal)
    }
    
    func parseBigPoints() -> String {
        return getSubstringBetweenPrefix("big_points_\(track.id) = ", andSuffix: ";")
    }
    
    func parsePostPoints() -> String {
        return getSubstringBetweenPrefix("post_points_\(track.id) = ", andSuffix: ";")
    }
    
    func serializeString(string: String) -> NSArray {
        var error: NSError?
        let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(string.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.MutableContainers, error: &error)
        if error != nil {
            println(error)
        }
        return json as NSArray
    }
    
    func getSubstringBetweenPrefix(prefix: String, andSuffix suffix: String) -> String {
        let prefixRange = Range(start: html.rangeOfString(prefix)!.endIndex, end: html.endIndex)
        var substring = html.substringWithRange(prefixRange)
        
        let suffixRange = Range(start: substring.startIndex, end: substring.rangeOfString(suffix)!.startIndex)
        substring = substring.substringWithRange(suffixRange)
        return substring
    }
}
