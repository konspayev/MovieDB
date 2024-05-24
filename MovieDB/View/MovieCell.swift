//
//  MoviceCell.swift
//  NoStoryTest
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
        movieImage.image = image
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
    
        movieStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
        }
        
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
