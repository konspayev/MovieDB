//
//  Theme.swift
//  NoStoryTest
//
//  Created by Nursultan Konspayev on 19.05.2024.
//

import Foundation

enum Theme {
    case popular
    case nowPlaying
    case upcoming
    case topRated
    
    /// UI presentation
    var title: String {
        switch self {
        case .nowPlaying: "Now Playing"
        case .popular: "Popular"
        case .upcoming: "Upcoming"
        case .topRated: "Top Rated"
        }
    }
    
    /// Network layer
    var url: String {
        switch self {
        case .popular:
            return "popular"
        case .nowPlaying:
            return "now_playing"
        case .upcoming:
            return "upcoming"
        case .topRated:
            return "top_rated"
        }
    }
}
