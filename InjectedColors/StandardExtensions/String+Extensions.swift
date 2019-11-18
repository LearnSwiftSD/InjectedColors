//
//  String+Extensions.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation

extension String {
    
    static var unassigned: String { "_UNASSIGNED" }
    
    var isUnassigned: Bool { self == .unassigned }
    
}
