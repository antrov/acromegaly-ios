//
//  BluetoothPeripherialDelegate.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 01.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BluetoothServiceImpl: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil, let serviceCharacteristics = service.characteristics else { return }
        
        serviceCharacteristics.forEach { (characteristic) in
            guard let characteristicType = BluetoothConstants.Characteristic(rawValue: characteristic.uuid.uuidString) else { return }
            self.handlers[characteristicType] = CharacteristicHandler(characteristic)
        }
        
        guard handlers.count == BluetoothConstants.Characteristic.allCases.count else { return }
        state = .connected
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("didWriteValueFor", characteristic.uuid.uuidString, error?.localizedDescription ?? "")
        guard let characteristicType = BluetoothConstants.Characteristic(rawValue: characteristic.uuid.uuidString) else { return }
        
        switch characteristicType {
        case .controlChar:
            didWriteControlCommand(error: error)
        default:
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("didUpdateValueFor", characteristic.uuid.uuidString, error?.localizedDescription ?? "")
        guard let characteristicType = BluetoothConstants.Characteristic(rawValue: characteristic.uuid.uuidString), let data = characteristic.value else { return }
        
        switch characteristicType {
        case .statusChar:
            didReceiveStatus(data: data, asSubscription: characteristic.isNotifying)
        default:
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        print("didUpdateNotificationStateFor", characteristic.uuid.uuidString, error?.localizedDescription ?? "")
        guard let characteristicType = BluetoothConstants.Characteristic(rawValue: characteristic.uuid.uuidString) else { return }
        
        switch characteristicType {
        case .statusChar:
            didChangeStatusSubscription(enabled: characteristic.isNotifying, error: error)
        default:
            return
        }
    }
    
}
