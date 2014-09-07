//
//  PopularPlaylistViewController.swift
//  Plug
//
//  Created by Alex Marchant on 8/31/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Cocoa

class PopularPlaylistViewController: BasePlaylistViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = PopularPlaylistDataSource(playlistSubType: .Now, viewController: self)
    }
}
