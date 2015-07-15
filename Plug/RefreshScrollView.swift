//
//  RefreshScrollView.swift
//  Plug
//
//  Created by Alex Marchant on 7/13/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class RefreshScrollView: NSScrollView {
    let delegate: RefreshScrollViewDelegate
    
    var refreshHeaderController: RefreshHeaderViewController!
    var refreshClipView: RefreshClipView {
        return contentView as! RefreshClipView
    }
    
    init(delegate: RefreshScrollViewDelegate) {
        self.delegate = delegate
        super.init(frame: NSZeroRect)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                startRefresh()
            }
        default:
            break
        }
        
        super.scrollWheel(theEvent)
    }
    
    func scrolledPastTopOfRefreshHeader() -> Bool {
        return refreshClipView.bounds.origin.y <= -refreshHeaderController.viewHeight
    }
    
    func scrolledPastTopOfContentView() -> Bool {
        return contentView.bounds.origin.y < 0
    }
    
    func startRefresh() {
        refreshHeaderController.state = .Updating
        delegate.didPullToRefresh()
    }
    
    func finishedRefresh() {
        documentView!.scrollPoint(NSZeroPoint)

        refreshHeaderController.state = .PullToRefresh
        refreshHeaderController.lastUpdated = NSDate()
    }
}

protocol RefreshScrollViewDelegate {
    func didPullToRefresh()
}