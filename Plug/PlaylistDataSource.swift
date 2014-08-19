//
//  PlaylistDataSource.swift
//  Plug
//
//  Created by Alex Marchant on 8/12/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

protocol PlaylistDataSource: NSTableViewDataSource {
    var tableView: NSTableView? { get set }
    func loadInitialValues()
    func loadNextPage()
    func trackForRow(row: Int) -> Track
}
