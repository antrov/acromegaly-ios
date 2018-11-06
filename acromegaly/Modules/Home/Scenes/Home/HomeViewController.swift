//
//  HomeViewController.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit
import PromiseKit

protocol HomeController: class {
    func updateBluetooth(state: BluetoothState)
    func updateTargetState(_ state: TargetPositionState)
    func updateTargetPosition(_ value: Int, scale: Double, animated: Bool)
    func updateCurrentPosition(_ value: Int, scale: Double, animated: Bool)
    func updateMovingState(_ isMoving: Bool)
    func updateHeightPickerItems(_ items: [Int], selectedIndex: Int)
    func updateFavourites(_ items: [FavouriteItem])
}

class HomeViewController: UIViewController, HomeController {
    
    @IBOutlet weak var stateView: BluetoothStateView!
    @IBOutlet weak var previewView: PositionPreviewView!
    @IBOutlet weak var heightField: HeightField!
    @IBOutlet weak var heightInputConstraint: NSLayoutConstraint!
    @IBOutlet weak var decrementTargetButton: UIButton!
    @IBOutlet weak var incrementTargetButton: UIButton!    
    @IBOutlet weak var favouritesCollectionView: UICollectionView!
    @IBOutlet weak var favouritesCollectionLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var favouritesHeightContraint: NSLayoutConstraint!
    
    @IBOutlet var heightPickerView: UIPickerView!
    @IBOutlet var heightAccessoryView: UIToolbar!
    
    private var interactor: HomeInteractor!
    
    private var isEnabled: Bool = true
    private var heightPickerItems: [Int]?
    private var favouriteItems: [FavouriteItem]?
    private var statusViewHiddingPromise: (promise: Promise<Void>, resolver: Resolver<Void>)?
    
    static func setup(interactor: HomeInteractor) -> HomeViewController {
        let controller: HomeViewController = UIStoryboard.home.instantiateViewController()
        controller.interactor = interactor
        interactor.controller = controller
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.controllerLoaded()
        
        previewView.delegate = self
        
        heightField.inputPickerView = heightPickerView
        heightField.inputAccessoryToolbar = heightAccessoryView
        
        favouritesCollectionView.register(FavouriteItemCell.nib, forCellWithReuseIdentifier: FavouriteItemCell.reuseIdentifier)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrameNotification(_:)), name: UIWindow.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupFavouritesCollectionLayout()
    }
    
    private func setupFavouritesCollectionLayout() {
        guard let items = favouriteItems else { return }
        
        let count = CGFloat(items.count)
        let inset = favouritesCollectionLayout.sectionInset.left + favouritesCollectionLayout.sectionInset.right
        let spacing = favouritesCollectionLayout.minimumInteritemSpacing
        let width = (view.bounds.width - spacing * (count - 1) - inset) / count
        
        favouritesHeightContraint.constant = width
        favouritesCollectionLayout.itemSize = CGSize(width: width, height: width)
    }
    
    private func setViewEnabled(_ enabled: Bool, animated: Bool) {
        guard enabled != isEnabled else { return }
        
        isEnabled = enabled
        
        heightField.isUserInteractionEnabled = enabled
        previewView.isUserInteractionEnabled = enabled
        incrementTargetButton.isEnabled = enabled
        decrementTargetButton.isEnabled = enabled
        favouritesCollectionView.visibleCells.forEach { (cell) in
            cell.isUserInteractionEnabled = enabled
        }
    }
    
    // MARK: Notifications
    
    @objc private func keyboardWillChangeFrameNotification(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        heightInputConstraint.constant = view.bounds.height - frame.origin.y
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: HomeController
    
    func updateFavourites(_ items: [FavouriteItem]) {
        favouriteItems = items
        favouritesCollectionView.reloadData()
        setupFavouritesCollectionLayout()
    }
    
    func updateHeightPickerItems(_ items: [Int], selectedIndex: Int) {
        heightPickerItems = items
        heightPickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
    }
    
    func updateBluetooth(state: BluetoothState) {
        stateView.setState(state)
        stateView.setHidden(state == .connected)
        setViewEnabled(state == .connected, animated: true)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = state != .connected && state != .poweredOff
//        statusViewHiddingPromise?.resolver.reject(PMKError.cancelled)
//
//        guard case .connected = state else { return }
//        statusViewHiddingPromise = Promise.pending()
//
    }
    
    func updateTargetPosition(_ value: Int, scale: Double, animated: Bool) {
        heightField.setValue(value, animated: animated)
        previewView.setTargetPosition(scale, animated: animated)
    }
    
    func updateCurrentPosition(_ value: Int, scale: Double, animated: Bool) {
        previewView.setCurrentPosition(scale, animated: animated)
    }
    
    func updateMovingState(_ isMoving: Bool) {
        previewView.isMoving = isMoving
    }
    
    func updateTargetState(_ state: TargetPositionState) {
        heightField.setHighlighted(state == .isEditing, animated: true)
        setViewEnabled(state != .isApplying, animated: true)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = state == .isApplying
    }
    
    // MARK: Actions
    
    @IBAction func heightInputCancelAction(_ sender: Any) {
        _ = heightField.resignFirstResponder()
    }
    
    @IBAction func heightInputDoneAction(_ sender: Any) {
        _ = heightField.resignFirstResponder()
        
        let selectedRow = heightPickerView.selectedRow(inComponent: 0)
        let value = heightPickerItems?[selectedRow] ?? 0
        
        interactor.setTargetPosition(withValue: value)
    }
    
    @IBAction func incrementTargetButtonAction(_ sender: Any) {
        interactor.incrementTargetPosition()
    }
    
    @IBAction func decrementTargetButtonAction(_ sender: Any) {
        interactor.decrementTargetPosition()
    }
}

extension HomeViewController: PositionPreviewViewDelegate {
    
    func previewView(didChange position: Double, snapped: Bool) {
        interactor.setTargetPosition(withScale: position)
    }
    
    func previewView(didApply position: Double, swiped: Bool, snapped: Bool) {
        interactor.isTargetEditing = false
        
        guard !snapped else { return }
        interactor.setTargetPosition(withScale: position)
    }
    
    func previewView(didBeginChange position: Double) {
        interactor.isTargetEditing = true
    }   
    
}

extension HomeViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return heightPickerItems?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let value = heightPickerItems?[row] else { return nil }
        return "\(value) mm"
    }    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: FavouriteItemCell.reuseIdentifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? FavouriteItemCell, let item = favouriteItems?[indexPath.item] else { return }
        
        cell.delegate = self
        cell.value = item.label
        cell.isSet = item.isSet
    }
    
}

extension HomeViewController: FavouriteItemCellDelegate {
    
    func favouriteItemCell(didAction cell: FavouriteItemCell) {
        guard let index = favouritesCollectionView.indexPath(for: cell)?.item else { return }
        interactor.favouriteAction(at: index)
    }
    
    func favouriteItemCell(didContext cell: FavouriteItemCell) {
        guard let index = favouritesCollectionView.indexPath(for: cell)?.item else { return }
        interactor.favouriteContextAction(at: index)
        
    }
    
}
