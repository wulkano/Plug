//
//  NavigationSection.swift
//  Plug
//
//  Created by Alex Marchant on 7/23/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

enum NavigationSection: Int {
    case Popular = 0
    case Favorites
    case Latest
    case Blogs
    case Feed
    case Genres
    case Friends
    case Search
    
    func windowTitle() -> String {
        switch self {
        case .Popular:
            return "Popular"
        case .Favorites:
            return "Favorites"
        case .Latest:
            return "Latest"
        case .Blogs:
            return "Blog Directory"
        case .Feed:
            return "Feed"
        case .Genres:
            return "Genres"
        case .Friends:
            return "Friends"
        case .Search:
            return "Search"
        }
    }
}