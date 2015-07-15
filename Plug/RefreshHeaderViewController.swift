//
//  PullToRefreshViewController.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class RefreshHeaderViewController: NSViewController {
    let viewHeight: CGFloat = 30
    var state: PullToRefreshState = .PullToRefresh {
        didSet { stateChanged() }
    }
    var lastUpdated: NSDate? {
        didSet { lastUpdatedChanged() }
    }
    
    var loader: NSImageView!
    var messageLabel: NSTextField!
    
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
        loader.image = NSImage(named: "Loader-Refresh")
        background.addSubview(loader)
        loader.snp_makeConstraints { make in
            make.centerY.equalTo(background)
            make.size.equalTo(16)
            make.left.equalTo(background).offset(85)
        }
        
        messageLabel = NSTextField()
        messageLabel.editable = false
        messageLabel.selectable = false
        messageLabel.bordered = false
        messageLabel.drawsBackground = false
        messageLabel.lineBreakMode = .ByTruncatingTail
        messageLabel.font = NSFont(name: "HelveticaNeue-Medium", size: 13)
        messageLabel.textColor = NSColor(red256: 138, green256: 146, blue256: 150)
        background.addSubview(messageLabel)
        messageLabel.snp_makeConstraints { make in
            make.centerY.equalTo(background).offset(-2)
            make.left.equalTo(loader.snp_right).offset(5)
            make.right.lessThanOrEqualTo(background).offset(20)
        }
        
        updateMessageLabel()
    }
    
    func stateChanged() {
        updateLoader()
        updateMessageLabel()
    }
    
    func lastUpdatedChanged() {
        updateMessageLabel()
    }
    
    func updateLoader() {
        if self.state == .Updating {
            Animations.RotateClockwise(self.loader)
        } else {
            Animations.RemoveAllAnimations(self.loader)
        }
    }
    
    func updateMessageLabel() {
        switch state {
        case .PullToRefresh:
            messageLabel.stringValue = formattedTimestamp()
        case .ReleaseToRefresh:
            messageLabel.stringValue = state.label
        case .Updating:
            messageLabel.stringValue = state.label
        }
    }
    
    func formattedTimestamp() -> String {
        var formattedTimestamp = "Last Updated "
        
        if lastUpdated == nil {
            formattedTimestamp += "N/A"
        } else {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "h:mm a"
            formattedTimestamp += formatter.stringFromDate(lastUpdated!)
        }
        
        return formattedTimestamp
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