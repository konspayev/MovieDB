//
//  MoviceCell.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 06.05.2024.
//

import UIKit
import SnapKit

class MovieCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var movieImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.masksToBounds = true
        image.layer.cornerRadius = 30
        return image
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var favoriteImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "heart")
        image.tintColor = .red
        return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setImage(image: UIImage?) {
        activityIndicator.stopAnimating()
        movieImage.image = image
        movieImage.contentMode = .scaleAspectFill
    }
    
    func startLoadingImage() {
        activityIndicator.startAnimating()
        movieImage.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        movieImage.image = nil
        titleLabel.text = nil
    }
    
    private func setupLayout() {
        let movieStackView = UIStackView(arrangedSubviews: [movieImage, titleLabel])
        
        movieStackView.axis = .vertical
        movieStackView.spacing = 12
        
        contentView.addSubview(movieStackView)
        contentView.addSubview(activityIndicator)
    
        movieStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(movieImage)
        }
        
        movieImage.addSubview(favoriteImageView)
        favoriteImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.width.equalTo(60)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        favoriteImageView.isUserInteractionEnabled = true
        movieImage.isUserInteractionEnabled = true
        favoriteImageView.addGestureRecognizer(tap)
    }
    
    @objc
    func tap() {
        favoriteImageView.image = favoriteImageView.image == UIImage(systemName: "heart") ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
