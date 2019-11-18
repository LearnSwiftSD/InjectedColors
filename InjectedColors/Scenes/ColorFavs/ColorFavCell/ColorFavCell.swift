//
//  ColorFavCell.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import UIKit

class ColorFavCell : UITableViewCell, XibOnboardable {
    
    @IBOutlet weak var colorView: ColorView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hexLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func defaulSetUp() {
        let defaultColor = Color.Values(red: 0.5, green: 0.5, blue: 0.5)
        colorView.shiftTo(defaultColor)
        nameLabel.text = "Gray Color"
        hexLabel.text = "000000"
    }
    
}
