//
//  TrackGraph.swift
//  Plug
//
//  Created by Alexander Marchant on 7/17/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class TrackGraph: NSObject {
    var trackId: String
    var html: String
    var bigPoints: NSArray?
    var postPoints: NSArray?
    
    init(html: String, trackId: String) {
        self.trackId = trackId
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
    func relativeLast24HourData() -> (Double, Double) {
//        TODO this is erroring out for our of range reasons
//        let highRange: Double = 100
//        let data = last24HourData()
//        var beginPoint = data.0 / highRange
//        var endPoint = data.1 / highRange
//        if beginPoint > 1 { beginPoint = 1 }
//        if endPoint > 1 { endPoint = 1 }
//        return (beginPoint, endPoint)
        return (1, 1)
    }
    
    func last24HourData() -> (Double, Double) {
        var beginPointIndex: Int
        if bigPoints!.count < 26 {
            beginPointIndex = 1
        } else {
            beginPointIndex = bigPoints!.count - 26
        }
        let beginPointDict = bigPoints!.objectAtIndex(beginPointIndex) as NSDictionary
        var beginPointVal: Double = 0
        if beginPointDict["1"] is Int {
            beginPointVal = Double(beginPointDict["1"] as Int)
        } else if beginPointDict["1"] is Double {
            beginPointVal = beginPointDict["1"] as Double
        }
        let endPointDict = bigPoints!.objectAtIndex(bigPoints!.count - 2) as NSDictionary
        let endPointVal = endPointDict["1"] as Double
        return (beginPointVal, endPointVal)
    }
    
    func parseBigPoints() -> String {
        return getSubstringBetween("big_points_\(trackId) = ", suffix: ";")
    }
    
    func parsePostPoints() -> String {
        return getSubstringBetween("post_points_\(trackId) = ", suffix: ";")
    }
    
    func serializeString(string: String) -> NSArray {
        var error: NSError?
        let json: AnyObject! = NSJSONSerialization.JSONObjectWithData(string.dataUsingEncoding(NSUTF8StringEncoding), options: NSJSONReadingOptions.MutableContainers, error: &error)
        if error {
            println(error)
        }
        return json as NSArray
    }
    
    func getSubstringBetween(prefix: String, suffix: String) -> String {
        let prefixRange = Range(start: html.rangeOfString(prefix).endIndex, end: html.endIndex)
        var substring = html.substringWithRange(prefixRange)
        
        let suffixRange = Range(start: substring.startIndex, end: substring.rangeOfString(suffix).startIndex)
        substring = substring.substringWithRange(suffixRange)
        return substring
    }
}
