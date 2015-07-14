//
//  RefreshScrollView.swift
//  Plug
//
//  Created by Alex Marchant on 7/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class RefreshScrollView: NSScrollView {
    var refreshHeaderController: RefreshHeaderViewController!
    var refreshClipView: RefreshClipView {
        return contentView as! RefreshClipView
    }
    
    init() {
        super.init(frame: NSZeroRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        contentView = RefreshClipView()
    }
    
    override func viewDidMoveToSuperview() {
        loadRefreshView()
    }
    
    func loadRefreshView() {
        refreshHeaderController = RefreshHeaderViewController(nibName: nil, bundle: nil)!
        refreshClipView.addSubview(refreshHeaderController.view)
        refreshHeaderController.view.snp_makeConstraints { make in
            make.height.equalTo(refreshHeaderController.viewHeight)
            make.left.right.equalTo(refreshClipView)
            make.bottom.equalTo(refreshClipView.snp_top)
        }
    }
    
    override func scrollWheel(theEvent: NSEvent) {
        switch theEvent.phase {
        case NSEventPhase.Changed:
            if scrolledPastTopOfRefreshHeader() {
                refreshHeaderController.state = .ReleaseToRefresh
            } else {
                refreshHeaderController.state = .PullToRefresh
            }
        case NSEventPhase.Ended:
            if refreshHeaderController.state == .ReleaseToRefresh {
                refreshHeaderController.state = .Updating
            }
        default:
            break
        }

        super.scrollWheel(theEvent)
    }
    
    func scrolledPastTopOfRefreshHeader() -> Bool {
        return refreshClipView.bounds.origin.y <= -refreshHeaderController.viewHeight
    }
    
    func startRefresh() {
        refreshHeaderController.state = .Updating
    }
    
    func finishedRefresh() {
        refreshHeaderController.state = .PullToRefresh
        refreshHeaderController.lastUpdated = NSDate()
    }
}