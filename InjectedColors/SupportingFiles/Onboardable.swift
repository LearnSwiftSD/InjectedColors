//
//  Onboardable.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import UIKit
import Foundation

protocol Onboardable {
    
    static func create() -> Self
    
}

protocol StoryOnboardable: Onboardable { }

protocol XibOnboardable: Onboardable { }

extension StoryOnboardable where Self: UIViewController {
    
    static func create() -> Self {
        
        let className = String(describing: self)
        let failureMessage = "Failed to StoryOnboard \(className)"
        
        guard className.hasSuffix("Controller") else { fatalError(failureMessage) }
        
        let storyBoardName = className.replacingOccurrences(of: "ViewController", with: "")
        let storyboard = UIStoryboard(name: storyBoardName, bundle: Bundle.main)
        
        guard let viewController = storyboard.instantiateViewController(withIdentifier: className) as? Self else {
            fatalError(failureMessage)
        }
        
        return viewController
    }
    
}

extension XibOnboardable where Self: UIView {
    
    static func create() -> Self {
        
        let className = String(describing: self)
        let failureMessage = "NibOnboardable failed to instantiate \(className)"
        let followsViewNaming = className.hasSuffix("View") || className.hasSuffix("Cell")
        guard followsViewNaming else { fatalError(failureMessage) }
        
        let nibName = className.replacingOccurrences(of: "View", with: "")
        
        guard let view = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first as? Self else {
            fatalError(failureMessage)
        }
        
        return view
    }
    
}

