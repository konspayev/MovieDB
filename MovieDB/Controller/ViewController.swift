//
//  ViewController.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 27.04.2024.
//

import UIKit
import SnapKit
import CoreData
import Lottie

class ViewController: UIViewController {
//MARK: - Properties
    var movieData: [Results] = []
    
    private var favoriteMovie: [NSManagedObject] = []
    private var labelXPosition: Constraint!
    private var labelYPosition: Constraint!
    
    private lazy var movieLabel: UILabel = {
        let label = UILabel()
        label.text = "MovieDB"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        return label
    }()
    
    private lazy var disappearView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
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
    
    var errorAnimation: LottieAnimationView = {
        var animation = LottieAnimationView()
        animation = .init(name: "catinbox")
        animation.animationSpeed = 0.5
        animation.loopMode = .loop
        animation.play()
        return animation
    }()
    
 //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backButtonTitle = ""
        self.navigationController?.navigationBar.tintColor = .black
        
        setupViews()
        fetchMoviesForTheme(theme: currentTheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorite()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animate()
    }

//MARK: - Methods
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
    
    func animate() {
        UIView.animate(withDuration: 1) {
            self.movieLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 1) {
                self.movieLabel.transform = CGAffineTransform(scaleX: 0.8, y: 0.5)
            } completion: { _ in
                UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 1) {
                    self.animateToTheTop()
                    self.movieLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
                } completion: { _ in
                    self.disappearView.alpha = 1
                }
            }
        }
    }
    
    func animateToTheTop() {
        labelYPosition.update(offset:
        -(view.safeAreaLayoutGuide.layoutFrame.height/2) - 16)
        view.layoutSubviews()
    }


//MARK: - Setup Views
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(movieLabel)
        view.addSubview(disappearView)
        
        [labelTheme, themeCollectionView, tableView].forEach { disappearView.addSubview($0) }
                
        movieLabel.snp.makeConstraints { make in
            labelXPosition = make.centerX.equalTo(view.safeAreaLayoutGuide).constraint
            labelYPosition = make.centerY.equalTo(view.safeAreaLayoutGuide).constraint
        }
        
        disappearView.snp.makeConstraints { make in
            make.top.equalTo(movieLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        labelTheme.snp.makeConstraints { make in
            make.top.equalTo(movieLabel.snp.bottom)
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
