//
//  BluetoothCommunication.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 01.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import CoreBluetooth
import PromiseKit

extension BluetoothServiceImpl {
    
    // MARK: Request
    
    private typealias RequestComponents = (peripheral: CBPeripheral, handler: CharacteristicHandler)
    
    private func handleRequest<T>(for characteristic: BluetoothConstants.Characteristic, requestClousure: ((RequestComponents) throws -> ())) -> Promise<T> {
        guard let peripheral = peripheral else { return Promise(error: BluetoothError.noPeripheralConnected) }
        guard let handler = handlers[characteristic] else { return Promise(error: BluetoothError.characteristicNotDiscovered) }
        guard handler.pending?.promise.isResolved ?? true else { return Promise(error: BluetoothError.otherOperationPending) }
        
        let pendingPromise = Promise<Any>.pending()
        handler.pending = pendingPromise
        
        do {
            try requestClousure((peripheral, handler))
        } catch {
            pendingPromise.resolver.reject(error)
        }
        
        return pendingPromise.promise.map { $0 as! T }
    }
    
    func writeControl(command: BluetoothConstants.ControlCommand, value: Int16) -> Promise<Void> {
        var endian = value.littleEndian
        let size = MemoryLayout<Int16>.size
        let ptr = withUnsafePointer(to: &endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: size, {
                UnsafeBufferPointer(start: $0, count: size)
            })
        }
        
        return writeControl(command: command, value: Array(ptr))
    }

    func writeControl(command: BluetoothConstants.ControlCommand, value: [UInt8]) -> Promise<Void> {
        return handleRequest(for: .controlChar, requestClousure: { (peripheral, handler) in
            let bytes: [UInt8] = [command.rawValue] + value
            let data = Data(bytes: bytes)
            
            peripheral.writeValue(data, for: handler.characteristic, type: .withResponse)
        })
    }
    
    func readStatus() -> Promise<StatusValue> {
        return handleRequest(for: .statusChar) { (peripheral, handler) in
            peripheral.readValue(for: handler.characteristic)
        }
    }
    
    func subscribeStatus(enabled: Bool) -> Promise<Void> {
        return handleRequest(for: .statusChar) { (peripheral, handler) in
            guard handler.characteristic.isNotifying != enabled else { throw PMKError.cancelled }
            peripheral.setNotifyValue(enabled, for: handler.characteristic)
        }
    }
    
    // MARK: Response
    
    func didReceiveStatus(data: Data, asSubscription subscription: Bool) {
        guard
            let movement = BluetoothConstants.MovementType(rawValue: data[5]),
            let targetType = BluetoothConstants.CurrentTargetType(rawValue: data[4])
            else { return }
        
        let position = Int16(littleEndian: data.withUnsafeBytes { $0.pointee })
        let target = Int16(littleEndian: data.withUnsafeBytes { $0.advanced(by: 1).pointee })
        
        let statusValue = StatusValue(position: Int(position), target: Int(target),  targetType: targetType, movement: movement)
      
        guard !subscription else { notifyStatusValue(statusValue); return }
        guard let pending = handlers[.statusChar]?.pending, pending.promise.isPending else { return }
        
        pending.resolver.fulfill(statusValue)
    }
    
    func didChangeStatusSubscription(enabled: Bool, error: Error?) {
        guard let pending = handlers[.statusChar]?.pending, pending.promise.isPending else { return }
        
        if let error = error {
            pending.resolver.reject(error)
        } else {
            pending.resolver.fulfill(())
        }
    }
    
    func didWriteControlCommand(error: Error?) {
        guard let pending = handlers[.controlChar]?.pending, pending.promise.isPending else { return }
        
        if let error = error {
            pending.resolver.reject(error)
        } else {
            pending.resolver.fulfill(())
        }
    }
    
}
