//
//  StatusValue.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 03.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation

struct StatusValue {
    /// Current desk position, expressed in millimeters
    let position: Int
    
    /// Current desk target, expressed in millimeters. If equal 0 with ative movement, means target with extremum position
    let target: Int
    
    let targetType: BluetoothConstants.CurrentTargetType
    let movement: BluetoothConstants.MovementType
}
