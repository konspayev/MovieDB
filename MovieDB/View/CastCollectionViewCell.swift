//
//  CastCollectionViewCell.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 29.05.2024.
//

import UIKit
import SnapKit

class CastCollectionViewCell: UICollectionViewCell {
    lazy var imageActor: UIImageView = {
        let image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 25
        return image
    }()
    
    lazy var labelName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textAlignment = .left
        return label
    }()
    
    lazy var labelRole: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.textAlignment = .left
        label.layer.opacity = 0.8
        return label
    }()
    
    lazy var stackLabelsView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(imageActor)
        contentView.addSubview(stackLabelsView)
        
        stackLabelsView.addArrangedSubview(labelName)
        stackLabelsView.addArrangedSubview(labelRole)
        
        imageActor.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        
        stackLabelsView.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(imageActor.snp.trailing).offset(10)
        }
        
        labelName.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalToSuperview()
        }
        
        labelRole.snp.makeConstraints { make in
            make.top.equalTo(labelName).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(20)
            make.width.equalToSuperview()
        }
    }
}

extension CastCollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
