//
//  StickyTrackViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/9/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa
import HypeMachineAPI

class StickyTrackViewController: TracksViewController {
    var trackViewHeight: CGFloat {
        return tableView(tableView, heightOfRow: 0)
    }
    let shadowHeight: CGFloat = 7
    var viewHeight: CGFloat {
        return trackViewHeight + shadowHeight
    }
    var shadowView: NSImageView?
    var position: StickyTrackPosition = .Bottom {
        didSet { positionChanged() }
    }
    
    override var tableViewInsets: NSEdgeInsets {
        return NSEdgeInsetsZero
    }
    
    func positionChanged() {
        switch position {
        case .Top:
            addShadowToBottom()
        case .Bottom:
            addShadowToTop()
        }
    }
    
    func addShadowToBottom() {
        shadowView?.removeFromSuperview()
        
        scrollView.snp_remakeConstraints { make in
            make.edges.equalTo(self.view).insets(NSEdgeInsets(top: 0, left: 0, bottom: shadowHeight, right: 0))
        }
        
        shadowView = NSImageView()
        shadowView!.imageScaling = .ImageScaleAxesIndependently
        shadowView!.image = NSImage(named: "Sticky Track Shadow Bottom")
        view.addSubview(shadowView!)
        shadowView!.snp_makeConstraints { make in
            make.height.equalTo(shadowHeight)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    func addShadowToTop() {
        shadowView?.removeFromSuperview()
        
        scrollView.snp_remakeConstraints { make in
            make.edges.equalTo(self.view).insets(NSEdgeInsets(top: shadowHeight, left: 0, bottom: 0, right: 0))
        }
        
        shadowView = NSImageView()
        shadowView!.imageScaling = .ImageScaleAxesIndependently
        shadowView!.image = NSImage(named: "Sticky Track Shadow Top")
        view.addSubview(shadowView!)
        shadowView!.snp_makeConstraints { make in
            make.height.equalTo(shadowHeight)
            make.left.equalTo(self.view)
            make.top.equalTo(self.view)
            make.right.equalTo(self.view)
        }
    }
    
    // MARK: DataSourceViewController
    
    override func loadScrollViewAndTableView() {
        super.loadScrollViewAndTableView()
        
        scrollView.scrollEnabled = false
    }
    
    // MARK: BaseContentViewController
    
    // Override a bunch of stuff we don't need
    override func addLoaderView() {}
    override func subscribeToNotifications() {}
    override func setupStickyTrack() {}
    override var stickyTrackController: StickyTrackViewController {
        fatalError("Should not be loading this from here")
    }
    override func addStickyTrackAtPosition(position: StickyTrackPosition) {}
    override func removeStickyTrack() {}
    override func updateStickyTrack(track: HypeMachineAPI.Track) {}
}
