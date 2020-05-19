//
//  NavigationSection.swift
//  Plug
//
//  Created by Alex Marchant on 7/23/14.
//  Copyright (c) 2014 Plug. All rights reserved.
//

import Foundation

enum NavigationSection: Int {
    case popular = 0
    case favorites
    case latest
    case blogs
    case feed
    case genres
    case friends
    case search

    var title: String {
        switch self {
        case .popular:
            return "Popular"
        case .favorites:
            return "Favorites"
        case .latest:
            return "Latest"
        case .blogs:
            return "Blogs"
        case .feed:
            return "Feed"
        case .genres:
            return "Genres"
        case .friends:
            return "Friends"
        case .search:
            return "Search"
        }
    }

    var analyticsViewName: String {
        "MainWindow/\(self.title)"
    }
}

enum PopularSectionMode: String {
    case Now = "Now"
    case NoRemixes = "No Remixes"
    case OnlyRemixes = "Only Remixes"
    case LastWeek = "Last Week"

    static let navigationSection = NavigationSection.popular

    var title: String {
        self.rawValue
    }

    var params: [String: Any] {
        ["mode": self.slug]
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

    static let navigationSection = NavigationSection.favorites

    var title: String {
        self.rawValue
    }
}

enum LatestSectionMode: String {
    case All = "All"
    case Freshest = "Freshest"
    case NoRemixes = "No Remixes"
    case OnlyRemixes = "Only Remixes"

    static let navigationSection = NavigationSection.latest

    var title: String {
        self.rawValue
    }

    var params: [String: Any] {
        ["mode": self.slug]
    }

    var slug: String {
        switch self {
        case .All:
            return "all"
        case .Freshest:
            return "fresh"
        case .NoRemixes:
            return "noremix"
        case .OnlyRemixes:
            return "remix"
        }
    }
}

enum FeedSectionMode: String {
    case All = "All"
    case Friends = "Friends"
    case Blogs = "Blogs"

    static let navigationSection = NavigationSection.feed

    var title: String {
        self.rawValue
    }

    var params: [String: Any] {
        ["mode": self.slug]
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

    static let navigationSection = NavigationSection.search

    var title: String {
        self.rawValue
    }

    var params: [String: Any] {
        ["sort": self.slug]
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
