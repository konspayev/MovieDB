//
//  MovieDetailViewController.swift
//  NoStoryTest
//
//  Created by Nursultan Konspayev on 15.05.2024.
//

import UIKit
import SnapKit

class MovieDetailViewController: UIViewController {
    var movieData: MovieDetail?
    var movieID = 0
    
    var onScreenDismiss: (() -> Void)?
    
    lazy var scrollMovieDetail: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = true
        return scroll
    }()
    
    lazy var movieImage: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stackReleaseView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    lazy var genreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.dataSource = self
        collection.delegate = self
        collection.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: GenreCollectionViewCell.identifier)
        return collection
    }()
    
    lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.text = "Overview"
        return label
    }()
    
    lazy var overviewText: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Movie"
        apiRequest()
        setupViews()
        setupLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onScreenDismiss?()
    }
    
    func apiRequest() {
        let session = URLSession(configuration: .default)
        
        guard let requestUrl = urlComponent.url else { return }
        let task = session.dataTask(with: requestUrl) {
            data, response, error in
            guard let data = data else { return }
            if let movie = try? JSONDecoder().decode(MovieDetail.self, from: data)
            {
                DispatchQueue.main.async {
                    self.movieData = movie
                    self.content()
                    self.genreCollectionView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    private func setupViews() {
        view.addSubview(scrollMovieDetail)
        scrollMovieDetail.addSubview(movieImage)
        scrollMovieDetail.addSubview(titleLabel)
        
        scrollMovieDetail.addSubview(stackReleaseView)
        stackReleaseView.addArrangedSubview(releaseDateLabel)
        stackReleaseView.addArrangedSubview(genreCollectionView)
    }
    
    private func setupLayout() {
        scrollMovieDetail.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        movieImage.snp.makeConstraints { make in
            make.top.equalTo(scrollMovieDetail.snp.top)
            make.centerX.equalTo(scrollMovieDetail.snp.centerX)
            make.leading.equalTo(scrollMovieDetail.snp.leading).offset(32)
            make.trailing.equalTo(scrollMovieDetail.snp.trailing).offset(-32)
            make.height.equalTo(424)
            make.width.equalTo(309)
        }
        
        movieImage.snp.makeConstraints { make in
            make.top.equalTo(scrollMovieDetail.snp.top)
            make.centerX.equalTo(scrollMovieDetail.snp.centerX)
            make.leading.equalTo(scrollMovieDetail.snp.leading).offset(32)
            make.trailing.equalTo(scrollMovieDetail.snp.trailing).offset(-32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(movieImage.snp.bottom).inset(17)
            make.leading.equalTo(scrollMovieDetail.snp.leading).offset(32)
            make.trailing.equalTo(scrollMovieDetail.snp.trailing).offset(-32)
        }
        
        stackReleaseView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).inset(17)
            make.leading.equalTo(scrollMovieDetail.snp.leading).offset(32)
            make.trailing.equalTo(scrollMovieDetail.snp.trailing).offset(-32)
            make.bottom.equalTo(scrollMovieDetail.snp.bottom).offset(-17)
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        
        genreCollectionView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(releaseDateLabel.snp.bottom)
            make.height.equalTo(22)
        }
    }
    
    func content() {
        guard let movieData = movieData else { return }
        titleLabel.text = movieData.originalTitle
        releaseDateLabel.text = "Release Date: \(movieData.releaseDate ?? "Not announced")"
        overviewText.text = movieData.overview
        let urlString = urlImage + movieData.posterPath!
        let url = URL(string: urlString)
        DispatchQueue.global(qos: .userInteractive).async {
            if let data = try? Data(contentsOf: url!) {
                DispatchQueue.main.async {
                    self.movieImage.image = UIImage(data: data)
                }
            }
        }
    }
    
}

extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movieData?.genres?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: GenreCollectionViewCell.identifier, for: indexPath) as! GenreCollectionViewCell
        guard let genre = movieData?.genres?[indexPath.row].name else { return UICollectionViewCell() }
        cell.label.text = genre
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 22)
    }
}
                                    
