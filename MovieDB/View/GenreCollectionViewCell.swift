//
//  GenreCollectionViewCell.swift
//  NoStoryTest
//
//  Created by Nursultan Konspayev on 18.05.2024.
//

import UIKit
import SnapKit

class GenreCollectionViewCell: UICollectionViewCell {
    lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .blue
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GenreCollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
