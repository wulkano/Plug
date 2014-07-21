//
//  LovedCountPlaylistTableCellView.swift
//  Plug
//
//  Created by Alexander Marchant on 7/19/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class LovedCountPlaylistTableCellView: PlaylistTableCellView {
    @IBOutlet var lovedCountView: NSView
    
    override func mouseEntered(theEvent: NSEvent!) {
        super.mouseEntered(theEvent)
        lovedCountView.hidden = true
    }
    
    override func mouseExited(theEvent: NSEvent!) {
        super.mouseExited(theEvent)
        if playState == PlayState.NotPlaying {
            lovedCountView.hidden = false
        }
    }
    
    override func playStateChanged() {
        super.playStateChanged()
        
        switch playState {
        case .Playing:
            lovedCountView.hidden = true
        case .Paused:
            lovedCountView.hidden = true
        case .NotPlaying:
            lovedCountView.hidden = false
        }
    }
}
