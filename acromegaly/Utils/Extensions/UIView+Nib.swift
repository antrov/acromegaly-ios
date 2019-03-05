//
//  UIView+Nib.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 11.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

protocol NibView where Self: UIView {
    func loadNib() -> UIView
    func setupNib()
}

extension NibView {
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupNib() {
        let view = loadNib()
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        
        addSubview(view)
    }
}
