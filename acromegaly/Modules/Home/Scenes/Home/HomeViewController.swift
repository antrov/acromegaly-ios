//
//  HomeViewController.swift
//  Acromegaly
//
//  Created by Hubert Andrzejewski on 28.09.2018.
//  Copyright © 2018 Hubert Andrzejewski. All rights reserved.
//

import UIKit

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
    
    static func setup(interactor: HomeInteractor) -> HomeViewController {
        let controller: HomeViewController = UIStoryboard.home.instantiateViewController()
        controller.interactor = interactor
        interactor.controller = controller
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.controllerLoaded()
    }
    
    func updateBluetooth(state: BluetoothState) {
        bleStatusLabel.text = state.rawValue
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
    }
    
    lazy var prev: Double = self.stepper.value
    @IBAction func stepperChanged(_ sender: Any) {
        if stepper.value > prev {
            interactor.setTargetOneUp()
        } else {
            interactor.setTargetOneDown()
        }
        
        prev = stepper.value
    }
}
