//
//  HomeCoordinator.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import UIKit

protocol HomeCoordinator {
    func start()
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
    
}
