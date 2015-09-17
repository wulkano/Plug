//
//  BlogTableCellView.swift
//  Plug
//
//  Created by Alex Marchant on 10/20/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class BlogTableCellView: IOSStyleTableCellView {
    var nameTextField: NSTextField!
    var recentArtistsTextField: NSTextField!
    
    override var objectValue: AnyObject! {
        didSet {
            objectValueChanged()
        }
    }
    var blog: HypeMachineAPI.Blog {
        return objectValue as! HypeMachineAPI.Blog
    }
    
    func objectValueChanged() {
        if objectValue == nil { return }
        
        updateName()
        updateArtists()
    }
    
    func updateName() {
        nameTextField.stringValue = blog.name
    }
    
    func updateArtists() {
        recentArtistsTextField.stringValue = "Loading..."
        
        let params = ["page": 1, "count": 3]
        HypeMachineAPI.Requests.Blogs.showTracks(id: blog.id, optionalParams: params) {
            (tracks: [HypeMachineAPI.Track]?, error) in
            
            if error != nil {
                Notifications.post(name: Notifications.DisplayError, object: self, userInfo: ["error": error!])
                print(error!)
                return
            }
            
            var recentTracks = ""
            for (index, track) in tracks!.enumerate() {
                recentTracks = recentTracks + "\(track.artist)"
                if index < tracks!.count - 1 {
                    recentTracks = recentTracks + ", "
                }
            }
            self.recentArtistsTextField.stringValue = recentTracks
        }
    }
}
