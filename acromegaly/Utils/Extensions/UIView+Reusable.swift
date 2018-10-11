//
//  UIView+Reusable.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 10.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

protocol Reusable {
    static var nib: UINib { get }
    static var nibName: String { get }
    static var reuseIdentifier: String { get }
}

extension Reusable where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: nibName, bundle: nil)
    }
    
    static var nibName: String {
        return String(describing: self)
    }
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
