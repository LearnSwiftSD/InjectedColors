//
//  FavColorEntity.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation
import RealmSwift

final class FavColorEntity: Object, StorableProjecting {

    @objc dynamic var id: String = .unassigned
    
    @objc dynamic var red: Int = 0
    @objc dynamic var green: Int = 0
    @objc dynamic var blue: Int = 0
    @objc dynamic var name: String = .unassigned
    @objc dynamic var timeStamp: Double = 0.0
    
    override static func primaryKey() -> String? { "id" }
    
    convenience init(favColor: FavColor) {
        self.init()
        self.id = favColor.id
        self.red = favColor.color.red
        self.green = favColor.color.green
        self.blue = favColor.color.blue
        self.name = favColor.name ?? .unassigned
        self.timeStamp = favColor.timeStamp
        print(favColor.timeStamp == self.timeStamp)
    }
    
    static func get(with storable: FavColor) -> FavColorEntity {
        return FavColorEntity(favColor: storable)
    }
    
    func projection() -> FavColor {
        let color = Color.Values(red: red, green: green, blue: blue)
        let translatedName = name.isUnassigned ? nil : name
        return FavColor(color: color, name: translatedName, id: id, timeStamp: timeStamp)
    }
    
}
