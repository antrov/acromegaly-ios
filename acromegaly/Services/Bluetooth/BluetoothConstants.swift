//
//  BluetoothConstants.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 03.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import CoreBluetooth

enum BluetoothError: Error {
    case otherOperationPending
    case noPeripheralConnected
    case characteristicNotDiscovered
}

struct BluetoothConstants {
    
    enum Service: String, CaseIterable {
        case statusSerivce = "00005E1F-1212-EFDE-1523-785FEF13D123"
        case controlService = "00001EAD-1212-EFDE-1523-785F90190523"
    }
    
    enum Characteristic: String, CaseIterable {
        case statusChar = "0000FEED-1212-EFDE-1523-785FEF13D123"
        case controlChar = "00005010-1212-EFDE-1523-785F90190523"
    }
    
    enum ControlCommand: UInt8 {
        case stop = 0xAA
        case setTarget = 0x60
        case setExtremumTarget = 0x88
    }
    
    enum CurrentTargetType: UInt8 {
        case noTarget = 0
        case exactValue = 2
        case extremumMin = 4
        case extremumMax = 8
    }
    
    struct ExtremumPosition {
        static let bottom: UInt8 = 0xDD
        static let top: UInt8 = 0xFF
    }
    
    enum MovementType: UInt8 {
        case up = 0xCB
        case down = 0x92
        case none = 0xA1
    }
    
}

extension BluetoothConstants.Service {
    static func cbuuids() -> [CBUUID] {
        return self.allCases.map { CBUUID(string: $0.rawValue) }
    }
}
