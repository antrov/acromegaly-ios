//
//  HomeInteractor.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import PromiseKit

protocol HomeInteractor: class {
    var controller: HomeController? { get set }
    
    func controllerLoaded()
    func setTargetPosition(position: Int16)
    func setTargetOneUp()
    func setTargetOneDown()
}

final class HomeInteractorImpl: HomeInteractor {
   
    weak var controller: HomeController?
    
    private let coordinator: HomeCoordinator
    private lazy var bluetoothService: BluetoothService = ServiceLocator.inject()
    
    private var statusValue: StatusValue?
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStateChanged), name: .bluetoothStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStatusReceived), name: .bluetoothStatusReceived, object: nil)
    }
    
    func controllerLoaded() {
        bluetoothService.connect()
        
        nextState(state: .unknown)
    }
    
    func nextState(state: BluetoothState) {
        guard var index = BluetoothState.allCases.firstIndex(of: state) else { fatalError("No index") }
        if index + 1 >= BluetoothState.allCases.count {
            index = 0
        } else {
            index += 1
        }
        
        self.controller?.updateBluetooth(state: state)
        
        after(seconds: 1.5).done {
            self.nextState(state: BluetoothState.allCases[index])
        }
    }
    
    @objc private func bluetoothStateChanged(notification: Notification) {
        let state = bluetoothService.state
        
        controller?.updateBluetooth(state: state)
        
        if state == .unknown {
            bluetoothService.connect()
            return
        }
        
        guard state == .connected else { return }
        bluetoothService
            .getStatus()
            .done({ (statusValue) in
                self.controller?.updateStatuts(statusValue)
                self.statusValue = statusValue
            })
            .catch { (error) in
                print("bluetoth serror", error)
            }
    }
    
    @objc private func bluetoothStatusReceived(notification: Notification) {
        guard let state = notification.userInfo?["status"] as? StatusValue else { return }
        print("pos: \(state.position) tar: \(state.target)")
        controller?.updateStatuts(state)
        statusValue = state
    }
    
    func setTargetPosition(position: Int16) {
        bluetoothService
            .setStatusSubscription(enabled: true)
            .then { _ in
                self.bluetoothService.setTargetPosition(.exact(mm: position))
            }.catch { (error) in
                print("bluetoth serror", error)
            }
    }
    
    func setTargetOneUp() {
        guard let status = statusValue else { return }
        let target = status.target != 0 ? status.target : status.position
        setTargetPosition(position: Int16(target / 1000 + 10))
    }
    
    func setTargetOneDown() {
        guard let status = statusValue else { return }
        let target = status.target != 0 ? status.target : status.position
        setTargetPosition(position: Int16(target / 1000 - 10))
    }
    
    
}
