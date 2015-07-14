//
//  PullToRefreshViewController.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class RefreshHeaderViewController: NSViewController {
    let viewHeight: CGFloat = 64
    var state: PullToRefreshState = .PullToRefresh {
        didSet { stateChanged() }
    }
    var lastUpdated: NSDate? {
        didSet { updateTimestampLabel() }
    }
    
    var loader: NSImageView!
    var stateLabel: NSTextField!
    var timestampLabel: NSTextField!
    
    override func loadView() {
        view = NSView()
        
        let background = BackgroundBorderView()
        background.bottomBorder = true
        background.borderColor = NSColor(red256: 225, green256: 230, blue256: 233)
        view.addSubview(background)
        background.snp_makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        loader = NSImageView()
        loader.image = NSImage(named: "Loader-Small")
        background.addSubview(loader)
        loader.snp_makeConstraints { make in
            make.centerY.equalTo(background)
            make.size.equalTo(32)
            make.left.equalTo(background).offset(20)
        }
        
        stateLabel = NSTextField()
        stateLabel.editable = false
        stateLabel.selectable = false
        stateLabel.bordered = false
        stateLabel.drawsBackground = false
        stateLabel.lineBreakMode = .ByTruncatingTail
        stateLabel.font = NSFont(name: "HelveticaNeue-Medium", size: 14)
        background.addSubview(stateLabel)
        stateLabel.snp_makeConstraints { make in
            make.top.equalTo(background).offset(10)
            make.left.equalTo(background).offset(73)
            make.right.lessThanOrEqualTo(background).offset(20)
        }
        
        timestampLabel = NSTextField()
        timestampLabel.editable = false
        timestampLabel.selectable = false
        timestampLabel.bordered = false
        timestampLabel.drawsBackground = false
        timestampLabel.lineBreakMode = .ByTruncatingTail
        timestampLabel.font = NSFont(name: "HelveticaNeue-Medium", size: 13)
        timestampLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        background.addSubview(timestampLabel)
        timestampLabel.snp_makeConstraints { make in
            make.top.equalTo(stateLabel.snp_bottom).offset(0)
            make.left.equalTo(background).offset(73)
            make.right.lessThanOrEqualTo(background).offset(20)
        }
        
        updateStateLabel()
        updateTimestampLabel()
    }
    
    func stateChanged() {
        updateLoader()
        updateStateLabel()
    }
    
    func updateLoader() {
        if self.state == .Updating {
            Animations.RotateClockwise(self.loader)
        } else {
            Animations.RemoveAllAnimations(self.loader)
        }
    }
    
    func updateStateLabel() {
        stateLabel.stringValue = state.label
    }
    
    func updateTimestampLabel() {
        var formattedTimestamp = "Last Updated "
        
        if lastUpdated == nil {
            formattedTimestamp += "N/A"
        } else {
            formattedTimestamp += lastUpdated!.description
        }
        
        timestampLabel.stringValue = formattedTimestamp
    }

}

enum PullToRefreshState {
    case PullToRefresh
    case ReleaseToRefresh
    case Updating
    
    var label: String {
        switch self {
        case .PullToRefresh:
            return "Pull To Refresh"
        case .ReleaseToRefresh:
            return "Release To Refresh"
        case .Updating:
            return "Updating..."
        }
    }
}