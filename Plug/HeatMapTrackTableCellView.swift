//
//  HeatMapTrackTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import Alamofire

class HeatMapTrackTableCellView: TrackTableCellView {
    var heatMapView: HeatMapView!
    
    override func objectValueChanged() {
        super.objectValueChanged()
        if objectValue == nil { return }
        
        updateHeatMap()
    }
    
    override func mouseInsideChanged() {
        super.mouseInsideChanged()
        updateHeatMapVisibility()
    }
    
    override func playStateChanged() {
        super.playStateChanged()
        updateHeatMapVisibility()
    }
    
    func updateHeatMap() {
        self.heatMapView.heatMap = nil
        let originalTrackID = self.track.id
        
        Alamofire.request(.GET, "https://www.plugformac.com/data/heatmaps.json").validate().responseJSON {
            (_, _, result) in
            guard self.objectValue != nil && self.track.id == originalTrackID
                else { return }
            
            switch result {
            case .Success(let JSON):
                if let trackJSON = (JSON[self.track.id] as? NSDictionary) {
                    let startPoint = (trackJSON["beginningValue"]! as! NSNumber).doubleValue
                    let endPoint = (trackJSON["endValue"]! as! NSNumber).doubleValue
                    let heatMap = HeatMap(track: self.track, start: startPoint, end: endPoint)
                    self.heatMapView.heatMap = heatMap
                } else {
                    //                println("Heatmap missed for track: \(self.trackValue)")
                }
            case .Failure(_, let error):
                Swift.print(error as NSError)
            }
        }
    }
    
    func updateHeatMapVisibility() {
        heatMapView.hidden = !playPauseButton.hidden
    }
}
