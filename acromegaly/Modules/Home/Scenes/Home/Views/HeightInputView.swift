//
//  HeightInputView.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 17.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

@IBDesignable
final class HeightInputView: UIView {
    
    private lazy var valueLabel = UILabel(frame: .zero)
    private lazy var unitLabel = UILabel(frame: .zero)
    
    private var isHighlighted: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let valueSize = valueLabel.intrinsicContentSize
        let unitWidth = unitLabel.intrinsicContentSize.width
        let vFrame = CGRect(x: bounds.midX - valueSize.width / 1.5, y: 0, width: valueSize.width, height: bounds.height)
        let uFrame = CGRect(x: vFrame.maxX + 5, y: 0, width: unitWidth, height: bounds.height)
        
        valueLabel.frame = vFrame
        unitLabel.frame = uFrame
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard highlighted != isHighlighted else { return }
        
        isHighlighted = highlighted
        
        let color: UIColor = highlighted ? .turquoise : .teal
        let block = {
            self.valueLabel.textColor = color
            self.unitLabel.textColor = color
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: block)
        } else {
            block()
        }
        
    }
    
    func setValue(_ value: String, animated: Bool) {
        if animated {
            let labelTransition = CATransition()
            labelTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            labelTransition.type = .fade
            labelTransition.duration = 0.15
            
            valueLabel.layer.add(labelTransition, forKey: "kCATransitionPush")
        }
        
        valueLabel.text = value
        layoutSubviews()
    }
    
    // MARK: Private methods
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        valueLabel.textColor = .teal
        valueLabel.font = UIFont.systemFont(ofSize: 48, weight: .light)
        valueLabel.textAlignment = .center
        valueLabel.text = "142"
        
        unitLabel.textColor = .teal
        unitLabel.font = UIFont.systemFont(ofSize: 27, weight: .light)
        unitLabel.text = "cm"
        
        addSubview(valueLabel)
        addSubview(unitLabel)
    }
    
    
    
}
