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
            return "Blogs"
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

enum PopularSectionMode: String {
    case Now = "Now"
    case NoRemixes = "No Remixes"
    case OnlyRemixes = "Only Remixes"
    case LastWeek = "Last Week"
    
    static let navigationSection = NavigationSection.Popular
    
    var title: String {
        return self.rawValue
    }
    
    var params: [String: AnyObject] {
        return ["mode": self.slug]
    }
    
    var slug: String {
        switch self {
        case .Now:
            return "now"
        case .NoRemixes:
            return "noremix"
        case .OnlyRemixes:
            return "remix"
        case .LastWeek:
            return "lastweek"
        }
    }
}


enum FavoritesSectionPlaylist: String {
    case All = "All"
    case One = "Up"
    case Two = "Down"
    case Three = "Weird"
    
    static let navigationSection = NavigationSection.Favorites
    
    var title: String {
        return self.rawValue
    }
}

enum FeedSectionMode: String {
    case All = "All"
    case Friends = "Friends"
    case Blogs = "Blogs"
    
    static let navigationSection = NavigationSection.Feed
    
    var title: String {
        return self.rawValue
    }
    
    var params: [String: AnyObject] {
        return ["mode": self.slug]
    }
    
    var slug: String {
        switch self {
        case .All:
            return "all"
        case .Friends:
            return "friends"
        case .Blogs:
            return "blogs"
        }
    }
}

enum SearchSectionSort: String {
    case Newest = "Newest"
    case MostFavorites = "Most Favorites"
    case MostReblogged = "Most Reblogged"
    
    static let navigationSection = NavigationSection.Search
    
    var title: String {
        return self.rawValue
    }
    
    var params: [String: AnyObject] {
        return ["sort": self.slug]
    }
    
    var slug: String {
        switch self {
        case .Newest:
            return "latest"
        case .MostFavorites:
            return "loved"
        case .MostReblogged:
            return "posted"
        }
    }
}