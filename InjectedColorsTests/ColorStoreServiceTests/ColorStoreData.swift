//
//  ColorStoreData.swift
//  InjectedColorsTests
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation

struct ColorStoreData {
    
    private static let values: [FavColor] = [
        FavColor(
            color: Color.Values(
                red: 220,
                green: 222,
                blue: 255) ,
            name: "Snow"
        ),
        FavColor(
            color: Color.Values(
                red: 166,
                green: 84,
                blue: 78) ,
            name: "Rosy Brown"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Salmon"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Indian Red"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Brown Madder"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Scarlet"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Yellow Perch"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Wheat"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Green Olive"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Popcorn"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Sky Blue"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Cerulean"
        ),
        FavColor(
            color: Color.Values(
                red: 12,
                green: 16,
                blue: 18) ,
            name: "Lavender"
        ),
    ]
    
    static var allStorage: [String: FavColor] {
        return values.reduce([:]) {
            var accumulator = $0
            accumulator[$1.id] = $1
            return accumulator
        }
    }
    
    static let emptyStorage = [String: FavColor]()
    
    static var randomSingleStorage: [String: FavColor] {
        guard let color = values.shuffled().first else {
            fatalError("No Test Data to load from!")
        }
        return [color.id: color]
    }
    
    static var randomSingle: FavColor {
        guard let color = values.shuffled().first else {
            fatalError("No Test Data to load from!")
        }
        return color
    }
    
}
