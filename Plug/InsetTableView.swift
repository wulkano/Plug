//
//  InsetTableView.swift
//  Plug
//
//  Created by Alex Marchant on 6/16/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class InsetTableView: ExtendedTableView {
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
        clipView.automaticallyAdjustsContentInsets = false
        clipView.contentInsets = NSEdgeInsetsMake(0, 0, 47, 0)
        scrollView!.scrollerInsets = NSEdgeInsetsMake(0, 0, 47, 0)
    }
}
