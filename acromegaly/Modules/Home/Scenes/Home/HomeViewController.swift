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
    func updateStatuts(_ statusValue: StatusValue)
}

class HomeViewController: UIViewController, HomeController {
    
    private var interactor: HomeInteractor!
    
    @IBOutlet weak var bleStatusLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var targetTextField: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var snappped: UISwitch!
    
    @IBOutlet weak var stateView: BluetoothStateView!
    @IBOutlet weak var previewView: PositionPreviewView!
    
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
        
        after(seconds: 4).done {
            self.hide()
        }
    }
    
    func hide() {
//        stateView.setHidden(arc4random() % 2 == 0, animated: true)
        after(seconds: 2.25).done {
            self.hide()
        }
    }
    
    func updateBluetooth(state: BluetoothState) {
        bleStatusLabel.text = state.rawValue
        stateView.setState(state)
    }
    
    func updateStatuts(_ statusValue: StatusValue) {
        positionLabel.text = "\(statusValue.position / 1000) mm"
        targetLabel.text = "\(statusValue.target / 1000) mm"
        
        switch statusValue.movement {
        case .down:
            movementLabel.text = "down"
        case .up:
            movementLabel.text = "up"
        case .none:
            movementLabel.text = "none"
        }
    }
    
    @IBAction func goButtonAction(_ sender: Any) {
        guard let positionText = targetTextField.text, let position = Int16(positionText) else { return }
        interactor.setTargetPosition(position: position)
        previewView.setTargetPosition(Double(position)/429, animated: true)
    }
    
    var pos: Double = 0
    var tar: Double = 0
    @IBAction func lowerPosAction(_ sender: Any) {
        if pos <= tar { return }
        pos -= 4
        positionLabel.text = "\(pos) mm"
        previewView.setCurrentPosition(pos / 429, animated: true)
    }
    
    @IBAction func lowerTarAction(_ sender: Any) {
        if tar <= 0 { return }
        tar -= 10
        targetLabel.text = "\(pos) mm"
        previewView.setTargetPosition(tar / 429, animated: true)
    }
    
    @IBAction func upperPosAction(_ sender: Any) {
        if pos >= tar { return }
        pos += 4
        positionLabel.text = "\(pos) mm"
        previewView.setCurrentPosition(pos / 429, animated: true)
    }
    
    @IBAction func upperTarAction(_ sender: Any) {
        if tar >= 429 { return }
        tar += 10
        targetLabel.text = "\(pos) mm"
        previewView.setTargetPosition(tar / 429, animated: true)
    }

    @IBAction func moveAction(_ sender: Any) {
        simMove()
    }
    
    func simMove() {
        previewView.isMoving = snappped.isOn
        guard snappped.isOn else { return }
        
        if tar > pos {
            upperPosAction(snappped)
        } else {
            lowerPosAction(snappped)
        }
        let inter = Double(max(arc4random_uniform(5), 2)) / 10
//        print(inter)
        after(seconds: inter).done {
            self.simMove()
        }
    }
}

extension HomeViewController: PositionPreviewViewDelegate {
    
    func previewView(didChange position: Double, snapped: Bool) {
        targetLabel.text =  String(format: "%.2fmm", position * 429)
        tar = position * 429
    }
    
    func previewView(didApply position: Double, swiped: Bool) {
        targetLabel.text =  String(format: "%.2fmm", position * 429)
        tar = position * 429
        print("didApply", tar)
//        simMove()
    }
    
    func previewView(didBeginChange position: Double) {
        
    }
    
    
    
}
