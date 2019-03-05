//
//  FavouriteItemCell.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 25/10/2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

protocol FavouriteItemCellDelegate: class {
    func favouriteItemCell(didAction cell: FavouriteItemCell)
    func favouriteItemCell(didContext cell: FavouriteItemCell)
}

final class FavouriteItemCell: UICollectionViewCell, Reusable {
    
    @IBOutlet private weak var actionButton: UIButton!
    @IBOutlet private weak var valueLabel: UILabel!
    
    weak var delegate: FavouriteItemCellDelegate?
    
    private lazy var longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
    
    var value: String? {
        didSet {
            valueLabel.text = value
        }
    }
    
    var isSet: Bool = false {
        didSet {
            actionButton.isSelected = isSet
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            actionButton.isEnabled = isUserInteractionEnabled
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        actionButton.addGestureRecognizer(longPressRecognizer)
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        delegate?.favouriteItemCell(didAction: self)
    }
    
    @IBAction func longPressAction(_ sender: Any) {
        guard let recognizer = sender as? UIGestureRecognizer, recognizer.state == .began else { return }
        delegate?.favouriteItemCell(didContext: self)
    }
}
