//
//  InsetTableView.swift
//  Plug
//
//  Created by Alex Marchant on 6/16/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class InsetTableView: ExtendedTableView {
    var insets: NSEdgeInsets = NSEdgeInsetsMake(0, 0, 47, 0) {
        didSet { updateInsets() }
    }
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        updateInsets()
    }
    
    func updateInsets() {
        clipView.automaticallyAdjustsContentInsets = false
        clipView.contentInsets = insets
        scrollView!.scrollerInsets = insets
    }
}