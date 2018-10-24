//
//  HomeInteractor.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import Foundation
import PromiseKit

protocol HomeInteractor: class {
    var controller: HomeController? { get set }
    var targetState: TargetPositionState { get }
    var isTargetEditing: Bool { get set }
    
    func controllerLoaded()
    func setTargetPosition(withValue value: Int)
    func setTargetPosition(withScale scale: Double)
    func incrementTargetPosition()
    func decrementTargetPosition()
}

enum TargetPositionState {
    case normal
    case isEditing
    case isApplying
}

final class HomeInteractorImpl: HomeInteractor {
   
    weak var controller: HomeController?
    
    private let coordinator: HomeCoordinator
    private lazy var bluetoothService: BluetoothService = ServiceLocator.inject()
    
    private let positionChangeStep: Int = 5
    private let positionBaseValue: Int = 834
    private let positionSlideValue: Int = 429
    
    private var targetValue: Int?
    
    var isTargetEditing: Bool {
        get {
            return targetState == .isEditing
        }
        set {
            guard targetState != .isApplying else { return }
            targetState = newValue ? .isEditing : .normal
        }
    }
    
    var targetState: TargetPositionState = .normal {
        didSet {
            guard targetState != oldValue else { return }
            controller?.updateTargetState(targetState)
        }
    }
    
    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    func controllerLoaded() {
        setupTargetPossibleValues()
        
        bluetoothService.connect()
        
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStateChanged), name: .bluetoothStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStatusReceived), name: .bluetoothStatusReceived, object: nil)
    }
    
    // MARK: HomeInteractor
    
    func setTargetPosition(withScale scale: Double) {
        setTargetPosition(withValue: Int(Double(positionSlideValue) * scale) + positionBaseValue)
    }
    
    func setTargetPosition(withValue value: Int) {
        let value = min(max(positionBaseValue, value), positionBaseValue + positionSlideValue)
        var target: TargetPoisition
        
        switch value {
        case positionBaseValue + positionSlideValue:
            target = .maximum
        case positionBaseValue:
            target = .minimum
        default:
            target = .exact(mm: value)
        }
        
        if case .isEditing = targetState {
            controller?.updateTargetPosition(value, scale: scaleWithValue(value), animated: false)
        } else {
            requestTargetPosition(target)
        }
    }
   
    func incrementTargetPosition() {
        guard let target = targetValue else { return }
        setTargetPosition(withValue: target + positionChangeStep)
    }
    
    func decrementTargetPosition() {
        guard let target = targetValue else { return }
        setTargetPosition(withValue: target - positionChangeStep)
    }
    
    // MARK: Private
    
    private func scaleWithValue(_ value: Int) -> Double {
        return Double(value - positionBaseValue) / Double(positionSlideValue)
    }
    
    private func setupTargetPossibleValues() {
        let values = stride(from: positionBaseValue, to: positionBaseValue + positionSlideValue, by: 10).map { Int($0) }
        let selectedIndex = targetValue == nil ? 0 : values.firstIndex { (value) -> Bool in
            abs(value - self.targetValue!) <= self.positionChangeStep
        } ?? 0
        
        controller?.updateHeightPickerItems(values, selectedIndex: selectedIndex)
    }
    
    private func updateBluetoothStatus(_ status: StatusValue) {
        var target: Int
        
        switch status.targetType {
        case .exactValue:
            target = status.target
        case .extremumMax:
            target = positionBaseValue + positionSlideValue
        case .extremumMin:
            target = positionBaseValue
        case .noTarget:
            target = status.position
        }

        targetValue = target
        
        controller?.updateMovingState(status.movement != .none)
        controller?.updateCurrentPosition(status.position, scale: scaleWithValue(status.position), animated: true)
        controller?.updateTargetPosition(target, scale: scaleWithValue(target), animated: true)
        setupTargetPossibleValues()
        print("target is now \(target)mm \(scaleWithValue(target)) - type: \(status.targetType)")
    }
    
    private func requestTargetPosition(_ targetType: TargetPoisition) {
        guard case .normal = targetState else { return }
        
        targetState = .isApplying
        print("request Target:", targetType)
        
        bluetoothService
            .setStatusSubscription(enabled: true)
            .then { _ in
                self.bluetoothService.setTargetPosition(targetType)
            }
            .ensure {
                self.targetState = .normal
            }
            .catch { (error) in
                print("bluetoth serror", error)
            }
    }
    
    // MARK: Notifications
    
    @objc private func bluetoothStateChanged(notification: Notification) {
        let state = bluetoothService.state
        
        controller?.updateBluetooth(state: state)
        
        if state == .unknown {
            bluetoothService.connect()
            return
        }
        
        guard state == .connected else { return }
        bluetoothService
            .getStatus()
            .done({ (statusValue) in
                self.updateBluetoothStatus(statusValue)
            })
            .catch { (error) in
                print("bluetoth serror", error)
            }
    }
    
    @objc private func bluetoothStatusReceived(notification: Notification) {
        guard let statusValue = notification.userInfo?["status"] as? StatusValue else { return }
        self.updateBluetoothStatus(statusValue)
    }
    
    
    
    
}
