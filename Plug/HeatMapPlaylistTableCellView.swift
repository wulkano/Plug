//
//  PopularPlaylistTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 8/28/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class HeatMapPlaylistTableCellView: BasePlaylistTableCellView {
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
        HypeMachineAPI.HeatMapFor(trackValue,
            success: {heatMap in
                self.heatMapView.heatMap = heatMap
            }, failure: {error in
                Logger.LogError(error)
        })
    }
    
    func updateHeatMapVisibility() {
        if mouseInside {
            heatMapView.hidden = true
        } else {
            switch playState {
            case .Playing, .Paused:
                heatMapView.hidden = true
            case .NotPlaying:
                heatMapView.hidden = false
            }
        }
    }
}
