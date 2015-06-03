//
//  DataSourceViewController.swift
//  Plug
//
//  Created by Alex Marchant on 10/22/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class DataSourceViewController: BaseContentViewController, NSTableViewDelegate, ExtendedTableViewDelegate {
    @IBOutlet var tableView: ExtendedTableView!
    
    func requestInitialValuesFinished() {
        removeLoaderView()
    }
}
