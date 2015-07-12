//
//  LoveCountTrackTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoveCountTrackTableCellView: TrackTableCellView {
    var loveCount: ColorChangingTextField!
    
    override func objectValueChanged() {
        super.objectValueChanged()
        if objectValue == nil { return }
        
        updateLoveCount()
    }
    
    override func mouseInsideChanged() {
        super.mouseInsideChanged()
        updateLoveCountVisibility()
    }
    
    override func playStateChanged() {
        super.playStateChanged()
        updateLoveCountVisibility()
    }
    
    func updateLoveCount() {
        loveCount.objectValue = track.lovedCountNum
    }
    
    func updateLoveCountVisibility() {
        loveCount.hidden = !playPauseButton.hidden
    }
}