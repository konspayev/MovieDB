//
//  ViewController.swift
//  NoStoryTest
//
//  Created by Nursultan Konspayev on 27.04.2024.
//

import UIKit

class ViewController: UIViewController {

    private lazy var labelTheme: UILabel = {
        let label = UILabel()
        label.text = "Theme"
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    lazy var urlComponent: URLComponents = {
        var component = URLComponents()
        component.scheme = "https"
        component.host = "api.themoviedb.org"
        component.queryItems = [
            URLQueryItem(name: "api_key", value: "ced760785529022f787ac282841dc942")
        ]
        return component
    }()
    
    lazy var themeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(MovieThemeCollectionViewCell.self, forCellWithReuseIdentifier: MovieThemeCollectionViewCell.identifier)
    
        return collection
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 500
        tableView.separatorStyle = .none
        tableView.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        getThemeMovies(theme: currentTheme)
    }
}

extension ViewController {
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(labelTheme)
        view.addSubview(themeCollectionView)
        view.addSubview(tableView)
        
        labelTheme.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
        }
        
        themeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(labelTheme).offset(5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }
        
        self.themeCollectionView.allowsMultipleSelection = false
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(themeCollectionView)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
    }
    
    extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            themes.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = self.themeCollectionView.dequeueReusableCell(withReuseIdentifier: MovieThemeCollectionViewCell.identifier, for: indexPath) as? MovieThemeCollectionViewCell else { return UICollectionViewCell() }
            cell.changeTitle(title: themes[indexPath.row].title, isSelected: themes[indexPath.row] == currentTheme)
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 80, height: 25)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard currentTheme != themes[indexPath.row] else {
                return
            }
            currentTheme = themes[indexPath.row]
        }
    }
    
    extension ViewController: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return movieData.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
                return UITableViewCell()
            }
            
            let title = movieData[indexPath.row].title
            cell.setTitle(title: title)
            
            let urlImageString = "https://image.tmdb.org/t/p/w500" + movieData[indexPath.row].posterPath
            
            if let url = URL(string: urlImageString) {
                DispatchQueue.global(qos: .userInitiated).async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            cell.setImage(image: UIImage(data: data))
                        }
                    }
                }
            }
            
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let movieDetailViewController = MovieDetailViewController()
            movieDetailViewController.movieID = movieData[indexPath.row].id
            movieDetailViewController.onScreenDismiss = { [weak self] in
                self?.currentTheme = .popular
            }
            self.navigationController?.pushViewController(movieDetailViewController, animated: true)
        }
    }
}


