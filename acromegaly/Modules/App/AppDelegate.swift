//
//  AppDelegate.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 24.08.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit
import PromiseKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private var rootViewController: UINavigationController {
        return window!.rootViewController as! UINavigationController
    }
    
    private lazy var appCoordinator: AppCoordinator = AppCoordinatorImpl(navigation: self.rootViewController)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupServices()
        appCoordinator.start()
        return true
    }

    private func setupServices() {
        PromiseKit.conf.Q.map = .global()
        
        ServiceLocator.register(singleton: BluetoothServiceImpl() as BluetoothService)
        ServiceLocator.register(singleton: FavouritesServiceImp(favouritesCount: 4) as FavouritesService)
    }
}

