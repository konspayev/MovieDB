//
//  ViewController.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 27.04.2024.
//

import UIKit
import SnapKit
import CoreData

class ViewController: UIViewController {
    var movieData: [Results] = []
    
    private var favoriteMovie: [NSManagedObject] = []
    
    //Theme Collection View Cell, to choose a proper movie theme
    private let themes: [MovieTheme] = [.popular, .upcoming, .nowPlaying, .topRated]
    
    private var currentTheme = MovieTheme.popular
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "MovieDB"
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        
        setupViews()
        fetchMoviesForTheme(theme: currentTheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorite()
    }
    
    private func fetchMoviesForTheme(theme: MovieTheme) {
        NetworkManager.shared.loadMovies(theme: theme) { [weak self] result in
            self?.movieData = result
            self?.tableView.reloadData()
        }
    }
    
    func saveFavorite(movie: Results) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistantContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: "Favorites", in: context) else { return }
        let favoriteManager = NSManagedObject(entity: entity, insertInto: context)
        favoriteManager.setValue(movie.id, forKey: "movieId")
        favoriteManager.setValue(movie.posterPath, forKey: "posterPath")
        favoriteManager.setValue(movie.title, forKey: "title")
        do {
            try context.save()
        } 
        catch {
            print("error save")
        }
    }
    
    func deleteFavorite(movie: Results) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistantContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Favorites")
        let predicate = NSPredicate(format: "movieId == %@", "\(movie.id)")
        fetch.predicate = predicate
        do {
            let result = try context.fetch(fetch)
            guard let data = result.first else { return }
            context.delete(data)
        }
        catch let error as NSError {
            print(error)
        }
    }
    
    func loadFavorite() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistantContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Favorites")
        do {
            let result = try context.fetch(fetch)
            favoriteMovie = result
        }
        catch let error as NSError {
            print(error)
        }
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
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else { return UITableViewCell() }
        
        let result = movieData[indexPath.row]
        cell.conf(title: result.title, posterPath: result.posterPath)
       
        cell.isFavoriteMethod = { [weak self] _ in
            guard let self else { return }
            let isInFavorite = !self.favoriteMovie.filter({ ($0.value(forKeyPath: "movieId") as? Int) ==  result.id}).isEmpty
            cell.tapFavorite(isNotFavorite: !isInFavorite)
            if isInFavorite {
                self.deleteFavorite(movie: result)
            }
            else {
                self.saveFavorite(movie: result)
            }
            loadFavorite()
        }
        
        let isFavorite = !self.favoriteMovie.filter( { $0.value(forKeyPath: "movieId") as? Int == result.id } ).isEmpty
        cell.tapFavorite(isNotFavorite: isFavorite)
        
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

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return themes.count
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
        guard currentTheme != themes[indexPath.row] else { return }
        currentTheme = themes[indexPath.row]
        themeCollectionView.reloadData()
        fetchMoviesForTheme(theme: currentTheme)
    }
}
