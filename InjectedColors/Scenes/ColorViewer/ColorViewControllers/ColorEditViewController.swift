//
//  ColorEditViewController.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import UIKit

class ColorEditViewController: ColorViewController, StoryOnboardable {
    
    @IBOutlet weak var deleteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpWithExistingColor()
    }
    
    func setUpWithExistingColor(){
        guard let color = colorViewModel.existingFav?.color else { return }
        nameField.text = colorViewModel.existingFav?.name
        
        redSlider.setValue(color.float.red, animated: false)
        greenSlider.setValue(color.float.green, animated: false)
        blueSlider.setValue(color.float.blue, animated: false)
        
        hexValueLabel.text = color.hex
        redValue.text = "\(color.red)"
        greenValue.text = "\(color.green)"
        blueValue.text = "\(color.blue)"
    }
    
    @IBAction func editColor(_ sender: Any) {
        colorViewModel.didEditColor()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteColor(_ sender: Any) {
        colorViewModel.didDeleteColor()
        navigationController?.popViewController(animated: true)
    }
    
    override func setUpStyle() {
        super.setUpStyle()
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.borderColor = UIColor.red.cgColor
        deleteButton.layer.borderWidth = 2.5
    }
    
}
