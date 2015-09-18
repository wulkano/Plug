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
    let shadowOverlap: CGFloat = 1
    var viewHeight: CGFloat {
        return trackViewHeight + shadowHeight - shadowOverlap
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
            let insets = NSEdgeInsets(top: 0, left: 0, bottom: shadowHeight - shadowOverlap, right: 0)
            make.edges.equalTo(self.view).inset(insets)
        }
        
        shadowView = NSImageView()
        shadowView!.imageScaling = NSImageScaling.ScaleAxesIndependently
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
            let insets = NSEdgeInsets(top: shadowHeight - shadowOverlap, left: 0, bottom: 0, right: 0)
            make.edges.equalTo(self.view).inset(insets)
        }
        
        shadowView = NSImageView()
        shadowView!.imageScaling = NSImageScaling.ScaleAxesIndependently
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
    
    override func addLoaderView() {}
    
    override var shouldShowStickyTrack: Bool {
        return false
    }

    override var stickyTrackController: StickyTrackViewController {
        fatalError("Should not be loading this from here")
    }
}
