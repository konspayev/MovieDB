//
//  MovieDetailViewController.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 15.05.2024.
//

import UIKit
import SnapKit

class MovieDetailViewController: UIViewController {
    var movieData: MovieDetail?
    var movieID = 0
    let urlImage = "https://image.tmdb.org/t/p/w500"
    
    var onScreenDismiss: (() -> Void)?
    
    //MARK: - UIViews
    lazy var scrollMovieDetail: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = true
        scroll.alwaysBounceHorizontal = false
        return scroll
    }()
    
    lazy var contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var stackPosterView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var stackReleaseAndRatingView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    lazy var stackReleaseView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var stackRateView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var stackRatingStarsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var stackOverview: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.backgroundColor = .systemGray4
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    lazy var movieImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    lazy var genreCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collection = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(GenreCollectionViewCell.self, forCellWithReuseIdentifier: GenreCollectionViewCell.identifier)
        return collection
    }()
    
    lazy var voteCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textColor = .gray
        return label
    }()
    
    lazy var ratingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        label.text = "Overview"
        return label
    }()
    
    lazy var overviewText: UITextView = {
        let text = UITextView()
        text.isUserInteractionEnabled = false
        text.sizeToFit()
        text.isScrollEnabled = false
        text.textAlignment = .left
        text.backgroundColor = .systemGray4
        text.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return text
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Movie"
        
        
        setupViews()
        startLoadingImage()
        fetchMovieDetail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onScreenDismiss?()
    }
    
    //MARK: - Methods
    func fetchMovieDetail() {
        NetworkManager.shared.getMovieDetail(movieID: movieID) { result in
            print(self.movieID)
            self.movieData = result
            self.updateContent()
        }
    }
    
    func startLoadingImage() {
        activityIndicator.startAnimating()
        movieImage.image = nil
    }
    
    func updateContent() {
        guard let movieData = movieData else { return }
        titleLabel.text = movieData.originalTitle
        releaseDateLabel.text = "Release Date: \(movieData.releaseDate ?? "Not announced")"
        if let posterPath = movieData.posterPath {
            let urlString = NetworkManager.shared.imageURL + posterPath
            if let url = URL(string: urlString) {
                NetworkManager.shared.downloadImage(from: url) { [weak self] image in
                    self?.movieImage.image = image
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        genreCollectionView.reloadData()
        setRatingStars(rating: movieData.voteAverage ?? 0)
        ratingLabel.text = String(format: "%.1f/10", movieData.voteAverage ?? "No ratings")
        voteCountLabel.text = "\(movieData.voteCount ?? 0)K"
        overviewText.text = movieData.overview
        
    }
    
    func setRatingStars(rating: Double) {

        let fullStarCount = Int(rating / 2)
        
        let hasHalfStar = (rating.truncatingRemainder(dividingBy: 2)) >= 1.0
        
        for _ in 0..<fullStarCount {
            let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
            starImageView.tintColor = .systemYellow
            starImageView.snp.makeConstraints { make in
                make.width.equalTo(24)
                make.height.equalTo(24)
            }
            stackRatingStarsView.addArrangedSubview(starImageView)
        }
        
        if hasHalfStar {
            let halfStarImageView = UIImageView(image: UIImage(systemName: "star.leadinghalf.fill"))
            halfStarImageView.tintColor = .systemYellow
            halfStarImageView.snp.makeConstraints { make in
                make.width.equalTo(24)
                make.height.equalTo(24)
            }
            stackRatingStarsView.addArrangedSubview(halfStarImageView)
        }
        
        let emptyStars = 5 - fullStarCount - (hasHalfStar ? 1 : 0)
        
        for _ in 0..<emptyStars {
            let emptyStarImageView = UIImageView(image: UIImage(systemName: "star"))
            emptyStarImageView.tintColor = .systemYellow
            emptyStarImageView.snp.makeConstraints { make in
                make.width.equalTo(24)
                make.height.equalTo(24)
            }
            stackRatingStarsView.addArrangedSubview(emptyStarImageView)
        }
    }
    
    //MARK: - Setup UIViews and Layout
    func setupViews() {
        view.addSubview(scrollMovieDetail)
        
        scrollMovieDetail.addSubview(contentView)
        
        contentView.addArrangedSubview(stackPosterView)
        contentView.addArrangedSubview(stackReleaseAndRatingView)
        contentView.addArrangedSubview(stackOverview)
        
        stackPosterView.addArrangedSubview(movieImage)
        stackPosterView.addArrangedSubview(titleLabel)
        stackPosterView.addArrangedSubview(activityIndicator)
        
        stackReleaseAndRatingView.addArrangedSubview(stackReleaseView)
        stackReleaseAndRatingView.addArrangedSubview(stackRateView)
        
        stackReleaseView.addArrangedSubview(releaseDateLabel)
        stackReleaseView.addArrangedSubview(genreCollectionView)
        
        stackRateView.addArrangedSubview(stackRatingStarsView)
        stackRateView.addArrangedSubview(ratingLabel)
        stackRateView.addArrangedSubview(voteCountLabel)
        
        stackOverview.addArrangedSubview(overviewLabel)
        stackOverview.addArrangedSubview(overviewText)
        
        scrollMovieDetail.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(scrollMovieDetail.contentLayoutGuide.snp.top)
            make.leading.equalTo(scrollMovieDetail.contentLayoutGuide.snp.leading)
            make.trailing.equalTo(scrollMovieDetail.contentLayoutGuide.snp.trailing)
            make.bottom.equalTo(scrollMovieDetail.contentLayoutGuide.snp.bottom)
            make.leading.equalTo(scrollMovieDetail.frameLayoutGuide.snp.leading)
            make.trailing.equalTo(scrollMovieDetail.frameLayoutGuide.snp.trailing)
        }
        
        stackPosterView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        movieImage.snp.makeConstraints { make in
            make.top.equalTo(stackPosterView.snp.top)
            make.height.equalTo(424)
            make.width.equalTo(309)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(movieImage)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(movieImage.snp.bottom).offset(30)
        }
        
        stackReleaseAndRatingView.snp.makeConstraints { make in
            make.top.equalTo(stackPosterView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(stackOverview.snp.top).offset(-20)
        }
        
        stackReleaseView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(stackRateView.snp.leading)
            make.bottom.equalToSuperview()
        }
        
        stackRateView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        releaseDateLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        genreCollectionView.snp.makeConstraints { make in
            make.top.equalTo(releaseDateLabel.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview()
            make.height.greaterThanOrEqualTo(22)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        stackRatingStarsView.snp.makeConstraints { make in
            make.top.equalTo(releaseDateLabel.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(24)
        }
        
        ratingLabel.snp.makeConstraints { make in
            make.top.equalTo(stackRatingStarsView.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
        }
        
        voteCountLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
        }
        
        stackOverview.snp.makeConstraints { make in
            make.top.equalTo(stackReleaseView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-30)
        }
        
        overviewLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
        }
        
        overviewText.snp.makeConstraints { make in
            make.top.equalTo(overviewLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-30)
        }
        
    }
}

//MARK: - Genre Collection View Configuration
extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        movieData?.genres?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: GenreCollectionViewCell.identifier, for: indexPath) as! GenreCollectionViewCell
        if let genre = movieData?.genres?[indexPath.row].name {
            cell.label.text = genre
        }
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 22)
    }
}
                                    
