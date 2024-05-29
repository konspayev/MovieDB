//
//  FavoritesViewCellViewController.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 27.05.2024.
//

import UIKit
import SnapKit

class FavoritesViewCellViewController: UIViewController {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Favorites"
        label.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        return label
    }()
    
    lazy var movieTableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        return table
    }()
    
    lazy var movieData: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(movieTableView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(36)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(40)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-40)
        }
        
        movieTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(28)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension FavoritesViewCellViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath)
        return cell
    }
}
