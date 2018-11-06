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
    func favouriteAction(at index: Int)
    func favouriteContextAction(at index: Int)
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
    private lazy var favouritesService: FavouritesService = ServiceLocator.inject()
    
    private let positionChangeStep: Int = 5
    private let positionBaseValue: Int = 834
    private let positionSlideValue: Int = 429
    
    private var targetValue: Int?
    private var favouriteValues: [Int?]?
    
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
        setupFavouriteItems()
        
        bluetoothService.connect()
        
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStateChanged), name: .bluetoothStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bluetoothStatusReceived), name: .bluetoothStatusReceived, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(favouritesUpdated), name: .favouritesUpdated, object: nil)
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
    
    func favouriteAction(at index: Int) {
        guard let favourites = favouriteValues else { return }
        
        if let value = favourites[index] {
            setTargetPosition(withValue: value)
        } else if let target = targetValue {
            favouritesService.setFavourite(target, at: index)
        }
    }
    
    func favouriteContextAction(at index: Int) {
        guard let favouriteValue = favouriteValues?[index] else { return }
        
        firstly {
            coordinator.showFavouriteMenu(for: favouriteValue)
        }
        .done { (action) in
            self.applyFavouriteContextAction(action, at: index)
        }
        .catch(policy: .allErrors) { _ in }
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
    
    private func setupFavouriteItems() {
        let values = favouritesService.getFavorites()
        let items = values.map { value -> FavouriteItem in
            guard let value = value else { return FavouriteItem(isSet: false, value: nil, label: "home.favourites.item.save".localized()) }
            return FavouriteItem(isSet: true, value: value, label: String(format: "home.favourites.item.value".localized(), value))
        }
        
        favouriteValues = values
        controller?.updateFavourites(items)
    }
    
    private func updateBluetoothStatus(_ status: StatusValue) {
        var target: Int
        
        switch status.targetType {
        
        case .extremumMax:
            target = positionBaseValue + positionSlideValue
        case .extremumMin:
            target = positionBaseValue
        case .exactValue:
            guard status.target != 0 else { fallthrough }
            target = status.target
        default:
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
        
        bluetoothService
            .setStatusSubscription(enabled: true)
            .then { _ in
                self.bluetoothService.setTargetPosition(targetType)
            }
            .ensure {
                self.targetState = .normal
            }
            .catch { (error) in
                print("bluetoth error", error)
            }
    }
    
    private func applyFavouriteContextAction(_ action: FavouritesActionType, at index: Int) {
        switch action {
        case .update:
            guard let target = targetValue else { return }
            favouritesService.setFavourite(target, at: index)
        case .clear:
            favouritesService.clearFavorite(at: index)
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
                print("bluetoth error", error)
            }
    }
    
    @objc private func bluetoothStatusReceived(notification: Notification) {
        guard let statusValue = notification.userInfo?["status"] as? StatusValue else { return }
        self.updateBluetoothStatus(statusValue)
    }
    
    @objc private func favouritesUpdated(notification: Notification) {
        setupFavouriteItems()
    }
    
}
