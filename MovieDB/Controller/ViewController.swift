//
//  ViewController.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 27.04.2024.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    //Theme Collection View Cell, to choose a proper movie theme
    private let themes: [MovieTheme] = [.popular, .upcoming, .nowPlaying, .topRated]
    
    private var currentTheme = MovieTheme.popular {
        didSet {
            fetchMoviesForCurrentTheme()
            themeCollectionView.reloadData()
        }
    }
    
    private lazy var labelTheme: UILabel = {
        let label = UILabel()
        label.text = "Theme"
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()
    
    lazy var themeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.allowsMultipleSelection = false
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
    
    var movieData: [Results] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "MovieDB"
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        
        setupViews()
        //getThemeMovies(theme: currentTheme)
        fetchMoviesForCurrentTheme()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(labelTheme)
        view.addSubview(themeCollectionView)
        view.addSubview(tableView)
        
        labelTheme.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(5)
        }
        
        themeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(labelTheme.snp.bottom).offset(5)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(5)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-5)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
            make.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(themeCollectionView.snp.bottom).offset(5)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func fetchMoviesForCurrentTheme() {
        NetworkManager.shared.getThemeMovies(theme: currentTheme) { [weak self] result in
            switch result {
            case .success(let movies):
                self?.movieData = movies
                self?.tableView.reloadData()
            case .failure(let error):
                //Handle error (e.g., show an alert to the user)
                print("Error fetching movies: \(error.localizedDescription)")
            }
        }
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
        
        cell.startLoadingImage()
        
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
