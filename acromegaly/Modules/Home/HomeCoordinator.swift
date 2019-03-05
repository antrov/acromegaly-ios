//
//  HomeCoordinator.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit

protocol HomeCoordinator {
    func start()
    func showFavouriteMenu(for value: Int) -> Promise<FavouritesActionType>
}

final class HomeCoordinatorImpl: BaseCoordinator, HomeCoordinator {
    
    private weak var navigation: NavigationWrapper?
    
    init(parent: BaseCoordinator?, navigation: NavigationWrapper?) {
        self.navigation = navigation
        super.init(parent: parent)
    }
    
    func start() {
        showHome()
    }
    
    func showHome() {
        let interactor = HomeInteractorImpl(coordinator: self)
        let controller = HomeViewController.setup(interactor: interactor)
        navigation?.setRoot(controller, animated: false)
    }
    
    func showFavouriteMenu(for value: Int) -> Promise<FavouritesActionType> {
        let (promise, resolver) = Promise<FavouritesActionType>.pending()
        let controller = FavouritesActionControllerBuilder.build(for: value, result: resolver)
        
        navigation?.present(controller, source: .navigationController, animated: true)
        
        return promise.ensure {
            self.navigation?.dismiss(animated: true)
        }
    }
    
}
