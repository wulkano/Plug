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
    var boundsChangedDelegate: RefreshScrollViewBoundsChangedDelegate?
    
    var scrolling = false
    
    var refreshHeaderController: RefreshHeaderViewController!
    var refreshClipView: RefreshClipView {
        return contentView as! RefreshClipView
    }
    
    override var contentView: NSClipView {
        willSet { contentViewWillChange() }
        didSet { contentViewChanged() }
    }
    
    var scrollEnabled = true
    
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
    
    override func scrollWheel(with theEvent: NSEvent) {
        if !scrollEnabled { return }
        
        switch theEvent.phase {
        case NSEventPhase.changed:
            if scrolledPastTopOfRefreshHeader() {
                refreshHeaderController.state = .releaseToRefresh
            } else {
                refreshHeaderController.state = .pullToRefresh
            }
        case NSEventPhase.ended:
            if refreshHeaderController.state == .releaseToRefresh {
                startRefresh()
            }
        default:
            break
        }
        
        super.scrollWheel(with: theEvent)
    }
    
    func scrolledPastTopOfRefreshHeader() -> Bool {
        return refreshClipView.bounds.origin.y <= -refreshHeaderController.viewHeight
    }
    
    func scrolledPastTopOfContentView() -> Bool {
        return contentView.bounds.origin.y < 0
    }
    
    func startRefresh() {
        refreshHeaderController.state = .updating
        delegate.didPullToRefresh()
    }
    
    func finishedRefresh() {
        documentView!.scroll(NSZeroPoint)

        refreshHeaderController.state = .pullToRefresh
        refreshHeaderController.lastUpdated = Date()
    }
    
    func contentViewWillChange() {
        Notifications.unsubscribe(observer: self, name: NSNotification.Name.NSViewBoundsDidChange.rawValue, object: contentView)
    }
    
    func contentViewChanged() {
        contentView.postsFrameChangedNotifications = true
        Notifications.subscribe(observer: self, selector: #selector(contentViewBoundsDidChange), name: NSNotification.Name.NSViewBoundsDidChange.rawValue, object: contentView)
    }
    
    func contentViewBoundsDidChange(_ notification: Notification) {
        boundsChangedDelegate?.scrollViewBoundsDidChange(notification)
    }
}

protocol RefreshScrollViewDelegate {
    func didPullToRefresh()
}

protocol RefreshScrollViewBoundsChangedDelegate {
    func scrollViewBoundsDidChange(_ notification: Notification)
}
