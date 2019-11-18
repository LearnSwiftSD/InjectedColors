//
//  ColorSaveViewController.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import UIKit

class ColorSaveViewController: ColorViewController, StoryOnboardable {
    
    @IBAction func saveColor(_ sender: Any) {
        colorViewModel.didSaveColor()
        navigationController?.popViewController(animated: true)
    }
    
}
