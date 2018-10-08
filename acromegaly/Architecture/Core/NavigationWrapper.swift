//
//  NavigationWrapper.swift
//  PlayNow
//
//  Created by Jakub Lyskawka on 24/04/2018.
//  Copyright © 2018 N7 Mobile Sp. z o.o. All rights reserved.
//

import UIKit

enum PresentationSource {
    case navigationController
    case topController
}

protocol NavigationWrapper: ControllerWrapper {
    
    var hasRoot: Bool { get }
    var presentedController: ControllerWrapper? { get }
    
    func present(_ controller: ControllerWrapper, source: PresentationSource, animated: Bool)
    func push(_ controller: ControllerWrapper, animated: Bool)
    func pop(animated: Bool)
    func dismiss(animated: Bool)
    
    func setRoot(_ controller: ControllerWrapper, animated: Bool)
    func popToRoot(animated: Bool)
}

extension UINavigationController: NavigationWrapper {

    var hasRoot: Bool {
        return !viewControllers.isEmpty
    }
    
    var presentedController: ControllerWrapper? {
        return presentedViewController
    }
    
    func present(_ controller: ControllerWrapper, source: PresentationSource, animated: Bool) {
        switch source {
        case .navigationController:
            present(controller.controller, animated: animated)
        case .topController:
            guard let topController = topViewController else { return }
            topController.present(controller.controller, animated: animated)
        }
    }
    
    func push(_ controller: ControllerWrapper, animated: Bool) {
        pushViewController(controller.controller, animated: animated)
    }
    
    func pop(animated: Bool) {
        popViewController(animated: animated)
    }
    
    func dismiss(animated: Bool) {
        dismiss(animated: animated, completion: nil)
    }
    
    func setRoot(_ controller: ControllerWrapper, animated: Bool) {
        setViewControllers([controller.controller], animated: animated)
    }
    
    func popToRoot(animated: Bool) {
        popToRootViewController(animated: animated)
    }
}

