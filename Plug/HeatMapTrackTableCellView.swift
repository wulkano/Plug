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
    @IBOutlet var heatMapView: HeatMapView!
    
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
        Alamofire.request(.GET, "http://www.plugformac.com/data/heatmaps.json").validate().responseJSON {
            (_, _, JSON, error) in
            
            if error != nil {
                println(error)
                return
            }
            
            if let trackJSON = (JSON?.valueForKeyPath(self.trackValue.id) as? NSDictionary) {
                let startPoint = (trackJSON["beginningValue"]! as! NSNumber).doubleValue
                let endPoint = (trackJSON["endValue"]! as! NSNumber).doubleValue
                let heatMap = HeatMap(track: self.trackValue, start: startPoint, end: endPoint)
                self.heatMapView.heatMap = heatMap
            } else {
//                println("Heatmap missed for track: \(self.trackValue)")
            }
        }
    }
    
    func updateHeatMapVisibility() {
        heatMapView.hidden = !playPauseButton.hidden
    }
}
