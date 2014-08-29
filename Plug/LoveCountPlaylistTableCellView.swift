//
//  PlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LoveCountPlaylistTableCellView: BasePlaylistTableCellView {
    @IBOutlet var loveCount: NSView!
    
    override func mouseInsideChanged() {
        super.mouseInsideChanged()
        updateLoveCountVisibility()
    }
    
    override func playStateChanged() {
        super.playStateChanged()
        updateLoveCountVisibility()
    }
    
    func updateLoveCountVisibility() {
        if mouseInside {
            loveCount.hidden = true
        } else {
            switch playState {
            case .Playing, .Paused:
                loveCount.hidden = true
            case .NotPlaying:
                loveCount.hidden = false
            }
        }
    }
}