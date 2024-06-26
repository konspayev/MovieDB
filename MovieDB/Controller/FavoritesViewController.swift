//
//  FavoritesViewCellViewController.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 27.05.2024.
//

import UIKit
import SnapKit
import CoreData


class FavoritesViewController: UIViewController {

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
        table.rowHeight = 500
        table.separatorStyle = .none
        table.register(MovieCell.self, forCellReuseIdentifier: MovieCell.identifier)
        return table
    }()
    
    lazy var movieData: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uploadData()
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
    
    func uploadData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistantContainer.viewContext
        let fetch = NSFetchRequest<NSManagedObject>(entityName: "Favorites")
        do {
            movieData = try context.fetch(fetch)
            movieTableView.reloadData()
        } catch let error as NSError {
            print(error)
        }
    }
}

extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        movieData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = movieTableView.dequeueReusableCell(withIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        let movie = movieData[indexPath.row]
        let posterPath = movie.value(forKeyPath: "posterPath") as? String
        let title = movie.value(forKeyPath: "title") as? String
        cell.conf(title: title ?? "", posterPath: posterPath ?? "")
        
        return cell
    }
}
