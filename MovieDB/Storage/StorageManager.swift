//
//  StorageManager.swift
//  MovieDB
//
//  Created by Nursultan Konspayev on 05.06.2024.
//

import Foundation

class StorageManager {
    
    static var shared = StorageManager()
    
    enum Keys: String {
        case watchList
    }
    
    private let userDefaults = UserDefaults.standard
    
    func saveData(_ object: Any?, key: String) {
        userDefaults.set(object, forKey: key)
    }
    
    func loadData(key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }
    
    func saveWatchList(_ id: Int, key: StorageManager.Keys) {
        if var arrayWatchList = loadData(key: key.rawValue) as? [Int] {
            arrayWatchList.append(id)
            saveData(arrayWatchList, key: key.rawValue)
        } else {
            var arrayWatchList: [Int] = []
            arrayWatchList.append(id)
            saveData(arrayWatchList, key: key.rawValue)
        }
    }
    
    func loadWatchList(key: StorageManager.Keys) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }
    
    func removeWatchList(id: Int, key: StorageManager.Keys) {
        guard var arrayWatchList = loadData(key: key.rawValue) as? [Int] else { return }
        guard let index = arrayWatchList.firstIndex(of: id) else { return }
        arrayWatchList.remove(at: index)
        saveData(arrayWatchList, key: key.rawValue)
    }
}
