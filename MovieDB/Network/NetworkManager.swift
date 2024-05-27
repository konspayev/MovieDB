//
//  NetworkManager.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 26.05.2024.
//

import UIKit
import Alamofire

// Enumeration representing different movie categories
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

final class NetworkManager {
    
    // Singleton instance for global access
    static let shared = NetworkManager()
    
    // Base URL for movie images
    private let imageURL = "https://image.tmdb.org/t/p/w500"
    
    // API key for authenticating requests to The Movie Database (TMDb)
    private let apiKey = "ced760785529022f787ac282841dc942"
    
    // URLSession instance for making network requests
    let session = URLSession(configuration: .default)

    // URLComponents template for constructing API URLs
    private lazy var urlComponent: URLComponents = {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        return component
    }()
    
    // Private initializer to enforce singleton pattern
    private init() {}

    // Fetches movies for a given theme
    // - Parameter theme: The theme/category of movies to fetch
    func getThemeMovies(theme: MovieTheme, completion: @escaping (Result <[Results], Error>) -> Void) {
        // Set the path for the selected movie theme
        urlComponent.path = "/3/movie/\(theme.url)"
        
        //Construct the full URL
        guard let requestUrl = urlComponent.url else { return }
        
        //Perform the network request
        session.dataTask(with: requestUrl) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                //Handle case where no data was returned
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                }
                return
            }
            
            do {
                //Decode the JSON data into ThemeMovie
                let response = try JSONDecoder().decode(ThemeMovie.self, from: data)
                //Pass the results back to caller
                DispatchQueue.main.async {
                    completion(.success(response.results))
                }
            }
            catch {
                //Handle JSON decoding errors
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
