//
//  ColorViewController.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Injectable
import UIKit

class ColorViewController: UIViewController {
    
    @IBOutlet weak var colorView: ColorView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var hexValueLabel: UILabel!
    
    @IBOutlet weak var redValue: UILabel!
    @IBOutlet weak var greenValue: UILabel!
    @IBOutlet weak var blueValue: UILabel!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var cancellables = Cancellables()
    @ScopedInjection var colorViewModel: ColorViewModel
    let serviceScope = InjectableServices.token(for: ColorViewModel.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpStyle()
        bindViewModel()
    }
    
    // MARK: - Subscriptions
    
    func bindViewModel() {
        
        let sliders = ColorViewSliders(
            red: redSlider,
            green: greenSlider,
            blue: blueSlider
        )
        
        nameField.delegate = colorViewModel.textFieldHandler
        
        colorViewModel
            .slidersPublisher(for: sliders)
            .supply(to: colorView.input.color)
            .store(in: &cancellables)
        
        colorViewModel
            .slidersPublisher(for: sliders)
            .map { $0.hex }
            .supply(to: hexValueLabel.input.text)
            .store(in: &cancellables)
        
        colorViewModel
            .slidersPublisher(for: sliders)
            .supply(to: colorViewModel.didChangeColor)
            .store(in: &cancellables)
        
        colorViewModel
            .redPublisher(for: redSlider)
            .map(Color.toDecimal)
            .map(String.init)
            .supply(to: redValue.input.text)
            .store(in: &cancellables)
        
        colorViewModel
            .greenPublisher(for: greenSlider)
            .map(Color.toDecimal)
            .map(String.init)
            .supply(to: greenValue.input.text)
            .store(in: &cancellables)
        
        colorViewModel
            .bluePublisher(for: blueSlider)
            .map(Color.toDecimal)
            .map(String.init)
            .supply(to: blueValue.input.text)
            .store(in: &cancellables)
        
        nameField
            .publisher(for: .editingChanged)
            .compactMap { $0.text }
            .supply(to: colorViewModel.didChangeName)
            .store(in: &cancellables)
        
        colorViewModel
            .keyboardWillShowPublisher
            .supply(to: keyboardWillShow)
            .store(in: &cancellables)
 
        colorViewModel
            .keyboardWillHidePublisher
            .supply(to: keyboardWillHide)
            .store(in: &cancellables)
        
        colorViewModel.didFinishBinding()
    }
    
    func setUpStyle() {
        let pHolderText = NSAttributedString(
            string: "Enter Color Name",
            attributes: [
                .font : UIFont.futuraMedium(pt: 18),
                .foregroundColor : UIColor.lightGray])
        nameField.attributedPlaceholder = pHolderText
    }
    
    @IBAction func cancelColor(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - Keyboard Management
extension ColorViewController {
    
    private func keyboardClearance(up: Bool, by: CGFloat? = nil) {
        if up {
            guard let clearance = by else { return }
            UIView.animate(
                withDuration: 1,
                delay: 0,
                options: [ .curveEaseOut ],
                animations: { [weak view] in view?.frame.origin.y = 0 - clearance} )
        } else {
            UIView.animate(
                withDuration: 1,
                delay: 0,
                options: [ .curveEaseOut ],
                animations: { [weak view] in view?.frame.origin.y = 0 } )
        }
    }
    
    var keyboardWillShow: (Notification) -> Void {
        return { [weak self] in
            guard
                let self = self,
                let keyboardFrame = ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                else { return }
            self.keyboardClearance(up: true, by: keyboardFrame.height)
        }
    }
    
    var keyboardWillHide: (Notification) -> Void {
        return { [weak self] _ in
            guard let self = self else { return }
            self.keyboardClearance(up: false)
        }
    }

}
