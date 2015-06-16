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
    
    var title: String {
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

enum PopularSectionMode {
    static let navigationSection = NavigationSection.Popular
    
    case Now
    case LastWeek
    case NoRemixes
    case RemixesOnly
    
    var title: String {
        switch self {
        case .Now:
            return "Now"
        case .LastWeek:
            return "Last Week"
        case .NoRemixes:
            return "No Remixes"
        case .RemixesOnly:
            return "Remixes Only"
        }
    }
}