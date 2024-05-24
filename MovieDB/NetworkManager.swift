//
//  NetworkManager.swift
//  NoStoryTest
//
//  Created by Nursultan Konspayev on 22.05.2024.
//

import Foundation

class NetworkManager {
    static var shared = NetworkManager()
    
    var movieData: [List] = []
    let urlImage = "https://image.tmdb.org/t/p/w500"
    let apiKey = "ced760785529022f787ac282841dc942"
    lazy var urlComponent: URLComponents = {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        return component
    }()
    let session = URLSession(configuration: .default)
   
    private let themes: [Theme] = [.popular, .upcoming, .nowPlaying, .topRated]
    
    private var currentTheme = Theme.popular {
        didSet {
            getThemeMovies(theme: currentTheme)
        }
    }

    private func getThemeMovies(theme: Theme) {
        urlComponent.path = "/3/movie/\(theme.url)"
        guard let requestUrl = urlComponent.url else { return }

        session.dataTask(with: requestUrl) { data, response, error in
            DispatchQueue.main.async(flags: .barrier) { [weak self] in
                guard let data = data, error == nil else {
                    print(data ?? "")
                    return
                }
                self?.handleResponse(data: data)
            }
        }.resume()
    }
    
    private func handleResponse(data: Data) {
        do {
            let response = try JSONDecoder().decode(ThemeMovie.self, from: data)
            self.movieData = response.results
        } catch {
            // TODO: error handling
            return print(error)
        }
    }
}



