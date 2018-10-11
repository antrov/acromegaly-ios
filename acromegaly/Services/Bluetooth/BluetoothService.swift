//
//  BluetoothService.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import CoreBluetooth
import PromiseKit

extension NSNotification.Name {
    static let bluetoothStateChanged = NSNotification.Name("BluetoothService.bluetoothStateChanged")
    static let bluetoothStatusReceived = NSNotification.Name("BluetoothService.bluetoothStatusReceived")
}

enum BluetoothState: String, CaseIterable {
    case unknown
    case poweredOff
    case poweredOn
    case scanning
    case connecting
    case connected
}

enum TargetPoisition {
    case exact(mm: Int16)
    case maximum
    case minimum
}

protocol BluetoothService: class {
    
    var state: BluetoothState { get }
    
    func connect()
    func disconnect()
    func getStatus() -> Promise<StatusValue>
    func setStatusSubscription(enabled: Bool) -> Promise<Void>
    func setTargetPosition(_ target: TargetPoisition) -> Promise<Void>
    func stopMovement() -> Promise<Void>
    
}

final class BluetoothServiceImpl: NSObject, BluetoothService {
    
    lazy var centralManager: CBCentralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: true])
    var peripheral: CBPeripheral?
    lazy var handlers: [BluetoothConstants.Characteristic: CharacteristicHandler] = [:]
    
    var state: BluetoothState = .unknown {
        didSet {
            guard state != oldValue else { return }
            NotificationCenter.default.post(name: .bluetoothStateChanged, object: nil)
        }
    }
    
    func connect() {
        guard centralManager.state == .poweredOn else { return }
        
        centralManager.scanForPeripherals(withServices: BluetoothConstants.Service.cbuuids(), options: nil)
        state = .scanning
    }
    
    func disconnect() {
        guard let peripheral = peripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    func getStatus() -> Promise<StatusValue> {
        return readStatus()
    }
    
    func setStatusSubscription(enabled: Bool) -> Promise<Void> {
        return subscribeStatus(enabled: enabled)
            .recover(policy: CatchPolicy.allErrors) { error in
                guard error.isCancelled else { throw error }
                return ()
            }
    }
    
    func setTargetPosition(_ target: TargetPoisition) -> Promise<Void> {
        switch target {
        case .maximum:
            return writeControl(command: .setExtremumTarget, value: [BluetoothConstants.ExtremumPosition.top])
        case .minimum:
            return writeControl(command: .setExtremumTarget, value: [BluetoothConstants.ExtremumPosition.bottom])
        case .exact(let mm):
            return writeControl(command: .setTarget, value: mm)
        }
    }
    
    func stopMovement() -> Promise<Void> {
        return writeControl(command: .stop, value: [])
    }
    
    func notifyStatusValue(_ statusValue: StatusValue) {
        NotificationCenter.default.post(name: .bluetoothStatusReceived, object: nil, userInfo: ["status": statusValue])
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhX", $0) }.joined()
    }
}
