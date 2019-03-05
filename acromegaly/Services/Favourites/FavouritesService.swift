//
//  FavouritesService.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 29/10/2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static let favouritesUpdated = NSNotification.Name("FavouritesService.favouritesUpdated")
}

protocol FavouritesService {
    func getFavorites() -> [Int?]
    func clearFavorite(at index: Int)
    func setFavourite(_ value: Int, at index: Int)
}

final class FavouritesServiceImp: FavouritesService {
    
    private let totalCount: Int
    
    init(favouritesCount: Int) {
        totalCount = favouritesCount
    }    
    
    func getFavorites() -> [Int?] {
        return (0..<totalCount).map { index in
            UserDefaults.standard.object(forKey: favouriteKey(for: index)) as? Int
        }
    }
    
    func setFavourite(_ value: Int, at index: Int) {
        UserDefaults.standard.set(value, forKey: favouriteKey(for: index))
        NotificationCenter.default.post(name: .favouritesUpdated, object: nil)
    }
    
    func clearFavorite(at index: Int) {
        UserDefaults.standard.removeObject(forKey: favouriteKey(for: index))
        NotificationCenter.default.post(name: .favouritesUpdated, object: nil)
    }
    
    private func favouriteKey(for index: Int) -> String {
        return "com.acromegaly.antrov.favourites.\(index)"
    }
    
}
