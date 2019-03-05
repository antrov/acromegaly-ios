//
//  FavouritesActionControllerBuilder.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 01/11/2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit
import PromiseKit

enum FavouritesActionType: String {
    case update
    case clear
}

final class FavouritesActionControllerBuilder {
    
    private init() {}
    
    static func build(for value: Int, result promiseResolver: Resolver<FavouritesActionType>) -> UIAlertController {
        let controller = UIAlertController(title: String(format: "home.favourites.action.title".localized(), value), message: nil, preferredStyle: .actionSheet)
        
        controller.addAction(UIAlertAction(title: "home.favourites.action.update".localized(), style: .default, handler: { _ in
            promiseResolver.fulfill(.update)
        }))
        
        controller.addAction(UIAlertAction(title: "home.favourites.action.clear".localized(), style: .destructive, handler: { _ in
            promiseResolver.fulfill(.clear)
        }))
        
        controller.addAction(UIAlertAction(title: "home.favourites.action.cancel".localized(), style: .cancel, handler: {  _ in
            promiseResolver.reject(PMKError.cancelled)
        }))
        
        return controller
    }
    
}
