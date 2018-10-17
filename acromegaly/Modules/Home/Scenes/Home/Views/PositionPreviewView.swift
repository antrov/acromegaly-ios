//
//  PositionPreviewView.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 11.10.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

protocol PositionPreviewViewDelegate: class {
    func previewView(didBeginChange position: Double)
    func previewView(didChange position: Double, snapped: Bool)
    func previewView(didApply position: Double, swiped: Bool)
}

@IBDesignable
final class PositionPreviewView: UIView, NibView {
    
    @IBOutlet weak var deskTopImageView: UIImageView!
    @IBOutlet weak var deskBottomImageView: UIImageView!
    @IBOutlet weak var targetLineImageView: UIImageView!
    
    private lazy var hapticFeedback = UISelectionFeedbackGenerator()
    
    private let fullTranslationY: CGFloat = 62
    private let velocitySwipeThreshold: CGFloat = 750
    
    private var panInitialValue: CGFloat = 0
    private var currentPos: CGFloat = 0.5
    private var targetPos: CGFloat = 0.5
    private var isSnapped: Bool = false
    private var isPanFinished: Bool = true
    
    var isMoving: Bool = false
    
    weak var delegate: PositionPreviewViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupNib()
    }
    
    func setCurrentPosition(_ position: Double, animated: Bool) {
        let duration: TimeInterval? = isMoving ? 0.5 : nil
        
        currentPos = CGFloat(position)
        setTranslation(currentPos * fullTranslationY, of: deskTopImageView, animated: animated, duration: duration, linear: isMoving)
    }
    
    func setTargetPosition(_ position: Double, animated: Bool) {
        targetPos = CGFloat(position)
        setTranslation(targetPos * fullTranslationY, of: targetLineImageView, animated: animated)
    }
    
    @IBAction func panGestureAction(_ sender: Any) {
        guard let panGesture = sender as? UIPanGestureRecognizer else { return }
        guard !isPanFinished || panGesture.state == .began else { return }
        
        if panGesture.state == .began {
            delegate?.previewView(didBeginChange: Double(targetPos))
            isPanFinished = false
        }
        
        let velocity = panGesture.velocity(in: self).y
        var translation = max(min(panGesture.translation(in: self).y + panInitialValue, fullTranslationY), 0)
        
        let swiped = abs(velocity) > velocitySwipeThreshold
        let snapped = abs(translation / fullTranslationY - targetPos) < 0.1
        
        if swiped {
            translation = velocity < 0 ? 0 : fullTranslationY
        } else if snapped {
            translation = currentPos * fullTranslationY
        }
        
        let position = Double(translation / fullTranslationY)
        
        if panGesture.state == .ended || swiped {
            isPanFinished = true
            panInitialValue = translation
            delegate?.previewView(didApply: position, swiped: swiped)
        } else if snapped != isSnapped {
            isSnapped = snapped
            
            if snapped {
                hapticFeedback.selectionChanged()
            }
        }
        
        setTranslation(translation, of: targetLineImageView, animated: snapped || swiped, bouncing: swiped)
        
        guard !isPanFinished else { return }
        delegate?.previewView(didChange: position, snapped: isSnapped)
    }
    
    private func setTranslation(_ translationY: CGFloat, of view: UIView, animated: Bool, bouncing: Bool = false, duration: TimeInterval? = nil, linear: Bool = false) {
        let opts: AnimationOptions = linear ? .curveLinear : .curveEaseInOut
        let dur: TimeInterval = duration ?? 0.2
        let block = { view.transform = CGAffineTransform(translationX: 0, y: translationY) }
        
        if !animated {
            block()
        } else if !bouncing {
            UIView.animate(withDuration: dur, delay: 0, options: opts, animations: block, completion: nil)
        } else {
            UIView.animate(withDuration: dur, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: opts, animations: block, completion: nil)
        }
    }
    
}
