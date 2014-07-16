//
//  PlaylistViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/14/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class Song: NSObject {
    var title = "Deep Blue"
    var artist = "Arcade Fire"
}

class PlaylistViewController: NSViewController {
    var tracks = [Track]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HypeMachineAPI.Tracks.popular(HypeMachineAPI.Tracks.PopularMode.Now, success: {tracks in
                self.tracks = tracks
            }, failure: {error in
                println(error)
            })
        
        // TODO ScrollView insets
    }
}