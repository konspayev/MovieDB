//
//  NetworkManager.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 26.05.2024.
//

import UIKit
import Alamofire
import Lottie

final class NetworkManager {
//MARK: - Properties
    static let shared = NetworkManager()
    
    let imageURL = "https://image.tmdb.org/t/p/w500"
    
    private let apiKey = "ced760785529022f787ac282841dc942"
    
    private lazy var urlComponent: URLComponents = {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        return component
    }()
    
//MARK: - Methods
    func loadMovies(theme: MovieTheme, completion: @escaping ([Results]) -> Void) {
        urlComponent.path = "/3/movie/\(theme.url)"
        guard let url = urlComponent.url else { return }
        
        AF.request(url).responseDecodable(of: ThemeMovie.self) { response in
            if let error = response.error {
                print(error)
            }
            let data = response.result
            if let result = try? data.get() {
                DispatchQueue.main.async {
                    completion(result.results)
                }
            }
        }
    }
    
    func loadMovieDetail(movieID: Int, completion: @escaping (MovieDetail) -> Void) {
        urlComponent.path = "/3/movie/\(movieID)"
        guard let requestUrl = urlComponent.url else { return }
        
        URLSession.shared.dataTask(with: requestUrl) { data, response, error in
            guard let data = data else {return}
            if let movie = try? JSONDecoder().decode(MovieDetail.self, from: data)
            {
                DispatchQueue.main.async {
                    completion(movie)
                }
            }
        }.resume()
    }
    
    func loadCast(movieId:Int, completion: @escaping ([Cast]) -> Void) {
        urlComponent.path = "/3/movie/\(movieId)/casts"
        guard let url = urlComponent.url else { return }
        
        AF.request(url).responseDecodable(of: MovieCast.self) { response in
            if let result = try? response.result.get() {
                DispatchQueue.main.async {
                    completion(result.cast)
                }
            }
        }
    }
    
    func loadImage(posterPath: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = imageURL + posterPath
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }.resume()
    }
}
