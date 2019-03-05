//
//  BluetoothCentralDelegate.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 01.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BluetoothServiceImpl: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            state = .poweredOn
            connect()
        default:
            state = .poweredOff
            disconnect()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        state = .connecting
        centralManager.stopScan()
        centralManager.connect(peripheral, options: nil)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        state = .unknown
    }
    
}
