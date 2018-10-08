//
//  Storyboard.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

extension UIStoryboard {

    static let home = UIStoryboard(name: "Home", bundle: nil)
    
    func instantiateViewController<T: UIViewController>() -> T {
        guard let id = NSStringFromClass(T.self).components(separatedBy: ".").last, let vc = instantiateViewController(withIdentifier: id) as? T else {
            fatalError("Could not instantiate view controller \(T.self) from storyboard \(self)")
        }
        
        return vc
    }
}
