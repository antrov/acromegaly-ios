//
//  HeightField.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 17.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

@IBDesignable
final class HeightField: UIView {
    
    private lazy var valueLabel = UILabel(frame: .zero)
    private lazy var unitLabel = UILabel(frame: .zero)
    private lazy var borderLayer = CALayer()
    
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapRecognizerAction(_:)))
    
    private var isHighlighted: Bool = false
    
    var inputPickerView: UIPickerView?
    var inputAccessoryToolbar: UIToolbar?
    
    override var inputView: UIView? {
        return inputPickerView
    }
    
    override var inputAccessoryView: UIView? {
        return inputAccessoryToolbar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            guard oldValue != isUserInteractionEnabled else { return }
//            super.isUserInteractionEnabled = isUserInteractionEnabled
            updateTintColor()
        }
    }
    
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
        borderLayer.frame = CGRect(x: 0, y: bounds.maxY - 2, width: bounds.width, height: 2)
    }
    
    func setHighlighted(_ highlighted: Bool, animated: Bool) {
        guard highlighted != isHighlighted && isUserInteractionEnabled else { return }
        
        isHighlighted = highlighted
        updateTintColor(animated: animated)
    }
    
    func setValue(_ value: Int, animated: Bool) {
        if animated {
            let labelTransition = CATransition()
            labelTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            labelTransition.type = .fade
            labelTransition.duration = 0.15
            
            valueLabel.layer.add(labelTransition, forKey: "kCATransitionPush")
        }
        
        valueLabel.text = "\(value)"
        layoutSubviews()
    }
    
    override func becomeFirstResponder() -> Bool {
        setHighlighted(true, animated: true)
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        setHighlighted(false, animated: true)
        return super.resignFirstResponder()
    }
    
    // MARK: Private methods
    
    private func setup() {
        valueLabel.textColor = .teal
        valueLabel.font = UIFont.systemFont(ofSize: 48, weight: .light)
        valueLabel.textAlignment = .center
        valueLabel.text = "142"
        
        unitLabel.textColor = .teal
        unitLabel.font = UIFont.systemFont(ofSize: 27, weight: .light)
        unitLabel.text = "mm"
        
        borderLayer.backgroundColor = UIColor.teal.cgColor
        
        addSubview(valueLabel)
        addSubview(unitLabel)
        
        layer.addSublayer(borderLayer)
        
        addGestureRecognizer(tapRecognizer)
    }
    
    private func updateTintColor(animated: Bool = true) {
        var tintColor: UIColor = .teal
        var borderColor: UIColor = .teal
        
        if !isUserInteractionEnabled {
            tintColor = .disabledGray
            borderColor = .disabledGray
        } else if isHighlighted {
            tintColor = .turquoise
        }
        
        let block = {
            self.valueLabel.textColor = tintColor
            self.unitLabel.textColor = tintColor
            self.borderLayer.backgroundColor = borderColor.cgColor
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, animations: block)
        } else {
            block()
        }
    }
    
    @objc private func tapRecognizerAction(_ sender: Any) {
        _ = becomeFirstResponder()
    }
    
    
    
}
