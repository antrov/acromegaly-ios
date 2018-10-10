//
//  BluetoothStateView.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 09.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

final class BluetoothStateView: UIView {
    
    private var isHidding: Bool = false
    private var state: BluetoothState = .unknown
    private lazy var stateLabel = UILabel(frame: .zero)
    
    @IBInspectable var neutralBackground: UIColor = .systemTintBlue
    @IBInspectable var errorBackground: UIColor = .red
    @IBInspectable var connectedBackground: UIColor = .blue
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        stateLabel.frame = bounds
    }
    
    // MARK: Public methods
    
    private func setup() {
        backgroundColor = neutralBackground
        
        stateLabel.textAlignment = .center
        stateLabel.textColor = .white
        stateLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        addSubview(stateLabel)
    }
    
    func setHidden(_ hidden: Bool, animated: Bool = true) {
        guard hidden != isHidding else { return }
        
        isHidding = hidden
        setTextHidden(hidden, animated: animated)
        setViewHidden(hidden, animated: animated)
    }
    
    func setState(_ state: BluetoothState, animated: Bool = true) {
        guard state != self.state else { return }
        
        self.state = state
        self.setBackgroundColor(for: state, animated: animated && !isHidding)
        self.setText(for: state, animated: animated && !isHidding)
    }
    
    // MARK: Private methods
    
    private func setBackgroundColor(for state: BluetoothState, animated: Bool) {
        if animated {
            let colorTransition = CATransition()
            colorTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            colorTransition.type = .fade
            colorTransition.duration = 0.3
            layer.add(colorTransition, forKey: "kCATransitionFillFade")
        }
        
        switch state {
        case .connected:
            backgroundColor = connectedBackground
        case .poweredOff,
             .unknown:
            backgroundColor = errorBackground
        default:
            backgroundColor = neutralBackground
        }
    }
    
    private func setText(for state: BluetoothState, animated: Bool) {
        if animated {
            let labelTransition = CATransition()
            labelTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            labelTransition.type = .push
            labelTransition.subtype = .fromBottom
            labelTransition.duration = 0.2
            
            stateLabel.layer.add(labelTransition, forKey: "kCATransitionPush")
        }
        
        switch state {
        case .unknown:
            stateLabel.text = "home.home.bluetoothstatusview.unknownd".localized()
        case .poweredOff:
            stateLabel.text = "home.home.bluetoothstatusview.poweredOff".localized()
        case .poweredOn:
            stateLabel.text = "home.home.bluetoothstatusview.poweredOn".localized()
        case .scanning:
            stateLabel.text = "home.home.bluetoothstatusview.scanning".localized()
        case .connecting:
            stateLabel.text = "home.home.bluetoothstatusview.connecting".localized()
        case .connected:
            stateLabel.text = "home.home.bluetoothstatusview.connected".localized()
       
        }
    }
    
    private func setTextHidden(_ hidden: Bool, animated: Bool) {
        stateLabel.layer.removeAllAnimations()
        
        if animated {
            let labelTransition = CATransition()
            labelTransition.timingFunction = CAMediaTimingFunction(name: .easeOut)
            labelTransition.type = .push
            labelTransition.subtype = hidden ? .fromTop : .fromBottom
            labelTransition.duration = 0.2
            labelTransition.timeOffset = hidden ? 0 : 0.2
            
            stateLabel.layer.add(labelTransition, forKey: "kCATransitionVisibility")
        }
        
        stateLabel.isHidden = hidden
    }
    
    private func setViewHidden(_ hidden: Bool, animated: Bool) {
        layer.removeAllAnimations()
        
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: [.curveEaseInOut], animations: {
            self.alpha = hidden ? 0 : 1
        }, completion: nil)
    }
    
}
