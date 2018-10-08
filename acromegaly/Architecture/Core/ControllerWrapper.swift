//
//  ControllerWrapper.swift
//  PlayNow
//
//  Created by Jakub Lyskawka on 24/04/2018.
//  Copyright © 2018 N7 Mobile Sp. z o.o. All rights reserved.
//

import UIKit

protocol ControllerWrapper: class {
    var controller: UIViewController { get }
}

extension UIViewController: ControllerWrapper {
    var controller: UIViewController {
        return self
    }
}
