// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let popular = try? JSONDecoder().decode(Popular.self, from: jsonData)

import Foundation

//MARK: - Enumeration representing different movie categories
enum MovieTheme {
    case popular
    case nowPlaying
    case upcoming
    case topRated
    
    // Title to be displayed for each category
    var title: String {
        switch self {
        case .nowPlaying: "Now Playing"
        case .popular: "Popular"
        case .upcoming: "Upcoming"
        case .topRated: "Top Rated"
        }
    }
    
    // URL path segment for each category
    var url: String {
        switch self {
        case .popular: return "popular"
        case .nowPlaying: return "now_playing"
        case .upcoming: return "upcoming"
        case .topRated: return "top_rated"
        }
    }
}

// MARK: - Movie
struct Movie: Codable {
    let dates: Dates
    let page: Int
    let results: [Results]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case dates, page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct ThemeMovie: Codable {
    let page: Int
    let results: [Results]
    let totalPages, totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Dates
struct Dates: Codable {
    let maximum, minimum: String
}

//MARK: - Languages
enum OriginalLanguage: String, Codable {
    case en = "en"
    case fr = "fr"
    case ja = "ja"
}

// MARK: - Results
struct Results: Codable {
    let adult: Bool
    let backdropPath: String
    let genreIDS: [Int]
    let id: Int
    let originalLanguage, originalTitle, overview: String
    let popularity: Double
    let posterPath, releaseDate, title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case genreIDS = "genre_ids"
        case id
        case originalLanguage = "original_language"
        case originalTitle = "original_title"
        case overview, popularity
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case title, video
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
