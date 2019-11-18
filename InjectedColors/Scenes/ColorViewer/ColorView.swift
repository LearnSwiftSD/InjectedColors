//
//  ColorView.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import UIKit

class ColorView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = frame.height * 0.05
        layer.borderWidth = 2.5
        layer.borderColor = UIColor.white.cgColor
    }
    
    func shiftTo(_ colorValue: Color.Values) {
        let floats = colorValue.float
        backgroundColor = UIColor(
            red: CGFloat(floats.red),
            green: CGFloat(floats.green),
            blue: CGFloat(floats.blue),
            alpha: 1
        )
    }
    
}
