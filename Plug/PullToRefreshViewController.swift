//
//  PullToRefreshViewController.swift
//  Plug
//
//  Created by Alex Marchant on 6/3/15.
//  Copyright (c) 2015 Plug. All rights reserved.
//

import Cocoa

class PullToRefreshViewController: NSViewController {
    @IBOutlet var loaderView: NSImageView!
    @IBOutlet var pullToRefreshButton: HyperlinkButton!
    @IBOutlet var lastUpdatedButton: HyperlinkButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear() {
    }
}