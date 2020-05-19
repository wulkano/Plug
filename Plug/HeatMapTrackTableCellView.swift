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

        Alamofire
            .request("https://www.plugformac.com/data/heatmaps.json", method: .get)
            .validate()
            .responseJSON { response in
            guard self.objectValue != nil && self.track.id == originalTrackID
                else { return }

            switch response.result {
            case .success(let JSON):
                if let representation = JSON as? [String: Any],
                    let trackJSON = representation[self.track.id] as? [String: Any] {
                    let startPoint = (trackJSON["beginningValue"]! as! NSNumber).doubleValue
                    let endPoint = (trackJSON["endValue"]! as! NSNumber).doubleValue
                    let heatMap = HeatMap(track: self.track, start: startPoint, end: endPoint)
                    self.heatMapView.heatMap = heatMap
                } else {
                    //                println("Heatmap missed for track: \(self.trackValue)")
                }
            case .failure(let error):
                Swift.print(error as NSError)
            }
            }
    }

    func updateHeatMapVisibility() {
        heatMapView.isHidden = !playPauseButton.isHidden
    }
}
