//
//  FindViewController.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 29.05.2024.
//

import UIKit
import SnapKit

class FindViewController: UIViewController {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Search"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        return label
    }()

    lazy var findBar: UISearchBar = {
        let search = UISearchBar()
        search.delegate = self
        search.placeholder = "Search"
        return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(findBar)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
        }
        
        findBar.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(5)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-5)
            make.height.equalTo(50)
        }
    }
}

extension FindViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchBar.text ?? "")
    }
}
