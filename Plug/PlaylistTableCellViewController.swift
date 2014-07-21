//
//  PlaylistTableCellViewController.swift
//  Plug
//
//  Created by Alexander Marchant on 7/21/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PlaylistTableCellViewController: NSViewController {
    var playlistType: PlaylistType
    
    init(playlistType: PlaylistType) {
        self.playlistType = playlistType
        super.init()
    }
    
    override func loadView()  {
        view = buildView()
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func buildView() -> NSView {
        let cellView = PlaylistTableCellView(frame: NSMakeRect(0, 0, 470, 64))
        var detailView = buildDetailView()
        cellView.addSubview(detailView)
        
        
        
        
        return cellView
    }
    
    func buildDetailView() -> NSView {
        switch playlistType {
        case .Popular:
            return buildHeatMapView()
        case .Latest, .Favorites, .Latest, .Feed, .Search:
            return buildColorChangingTextField()
        }
    }
    
    func buildHeatMapView() -> HeatMapView {
        let heatMapView = HeatMapView(frame: NSMakeRect(0, 0, 72, 64))
        return heatMapView
    }
    
    func buildColorChangingTextField() -> ColorChangingTextField {
        let textField = ColorChangingTextField(frame: NSMakeRect(0, 19, 72, 28))
        textField.font = NSFont(name: "Helvetica Neue Medium", size: 23)
        textField.alignment = NSTextAlignment.CenterTextAlignment
        return textField
    }
}
