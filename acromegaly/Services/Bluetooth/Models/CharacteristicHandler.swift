//
//  CharacteristicHandler.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 03.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import CoreBluetooth
import PromiseKit

class CharacteristicHandler {
    
    let characteristic: CBCharacteristic
    var pending: (promise: Promise<Any>, resolver: Resolver<Any>)?
    
    init(_ characteristic: CBCharacteristic) {
        self.characteristic = characteristic
    }
    
}
