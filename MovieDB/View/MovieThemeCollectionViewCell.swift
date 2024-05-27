//
//  MovieThemeCollectionViewCell.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 17.05.2024.
//

import UIKit
import SnapKit

class MovieThemeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ThemeCollectionViewCell"
    
    lazy var labelThemeCollectionCell: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIViews()
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//MARK: - Setup UI Views
    private func setupUIViews() {
        contentView.addSubview(labelThemeCollectionCell)
        
        labelThemeCollectionCell.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    func changeTitle(title: String, isSelected: Bool) {
        labelThemeCollectionCell.textColor = isSelected ? .white : .black
        contentView.backgroundColor = isSelected ? .red : .systemGray5
        labelThemeCollectionCell.text = title
    }
}
