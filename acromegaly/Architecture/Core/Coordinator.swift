//
//  Coordinator.swift
//  PlayNow
//
//  Created by Jakub Lyskawka on 24/04/2018.
//  Copyright © 2018 N7 Mobile Sp. z o.o. All rights reserved.
//

import Foundation

protocol Coordinator: class {
    func dumpTree()
    func handleDeeplink(_ deeplink: Deeplink)
}

class BaseCoordinator: Coordinator {
    
    weak var parent: BaseCoordinator?
    private var children = [WeakRef<BaseCoordinator>]()
    
    init(parent: BaseCoordinator?) {
        Logger.debug("Init: \(self)")
        parent?.addChild(self)
        self.parent = parent
    }
    
    deinit {
        Logger.debug("Deinit: \(self)")
        parent?.removeChild(self)
    }
    
    func canHandleDeeplink(_ deeplink: Deeplink) -> Bool {
        return false
    }
    
    func handleSupportedDeeplink(_ deeplink: Deeplink) {
        
    }
    
    final func dumpTree() {
        findRoot().dumpTree(level: 0)
    }
    
    final func handleDeeplink(_ deeplink: Deeplink) {
        handlerForDeeplink(deeplink)?.handleSupportedDeeplink(deeplink)
    }
    
    private func handlerForDeeplink(_ deeplink: Deeplink) -> BaseCoordinator? {
        let root = findRoot()
        var queue = [WeakRef(value: root)]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            guard let coordinator = current.value else { continue }
            
            if coordinator.canHandleDeeplink(deeplink) {
                return coordinator
            } else {
                queue.append(contentsOf: coordinator.children)
            }
        }
        
        return nil
    }
    
    private func addChild(_ coordinator: BaseCoordinator) {
        let ref = WeakRef(value: coordinator)
        
        if !children.contains(ref) {
            children.append(ref)
        }
    }
    
    private func removeChild(_ coordinator: BaseCoordinator) {
        let ref = WeakRef(value: coordinator)
        
        if let index = children.index(of: ref) {
            children.remove(at: index)
        }
    }
    
    private func findRoot() -> BaseCoordinator {
        var root = self
        
        while let newRoot = root.parent {
            root = newRoot
        }
        
        return root
    }
    
    private func dumpTree(level: Int) {
        print("\(String(repeating: "  ", count: level))> \(self)")
        
        for child in children {
            if let coordinator = child.value {
                coordinator.dumpTree(level: level + 1)
            }
        }
    }
}

struct WeakRef<T: AnyObject>: Equatable {
    
    weak var value: T?
    
    init(value: T) {
        self.value = value
    }
    
    static func ==(lhs: WeakRef<T>, rhs: WeakRef<T>) -> Bool {
        if let v1 = lhs.value, let v2 = rhs.value {
            return v1 === v2
        }
        
        return lhs.value == nil && rhs.value == nil
    }
}
