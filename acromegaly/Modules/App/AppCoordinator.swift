//
//  AppCoordinator.swift
//  PlayNow
//
//  Created by Jakub Lyskawka on 24/04/2018.
//  Copyright © 2018 N7 Mobile Sp. z o.o. All rights reserved.
//

import Foundation

protocol AppCoordinator: Coordinator {
    func start()
}

final class AppCoordinatorImpl: BaseCoordinator, AppCoordinator {
    
    private weak var navigation: NavigationWrapper?
    
    init(navigation: NavigationWrapper?) {
        self.navigation = navigation
        super.init(parent: nil)
    }
    
    func start() {
        runHome()
    }
    
    func runHome() {
        let coordinator = HomeCoordinatorImpl(parent: self, navigation: navigation)
        coordinator.start()
    }
    
//    func runOnboarding() {
//        let coordinator = OnboardingCoordinatorImpl(parent: self, navigation: navigation)
//        coordinator.start()
//    }
//
//    func runMainTabbar() {
//        let coordinator = MainTabBarCoordinatorImpl(parent: self)
//        let controller = MainTabBarViewController.setup(wrapperDelegate: coordinator)
//        coordinator.tabBarWrapper = controller
//        navigation?.setRoot(controller, animated: false)
//    }
}
