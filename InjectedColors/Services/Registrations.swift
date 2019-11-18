//
//  Registrations.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation
import Injectable

struct Registrations {
    
    static func build() {
     
        InjectableServices.register(service: ColorStoreService.self, Store<FavColor>())
        InjectableServices.register(service: ColorViewModel.self, ColorViewModelImpl())
        InjectableServices.register(service: ColorFavsViewModel.self, ColorFavsViewModelImpl())
        
    }
    
}
