//
//  FavColor.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation
import RealmSwift

struct FavColor: Storable {
    
    typealias EntityType = FavColorEntity
    
    var color: Color.Values
    var name: String?
    var id = UUID().uuidString
    var timeStamp = Date().timeIntervalSinceReferenceDate

    let sortPath: KeyPath<FavColor, TimeInterval> = \FavColor.timeStamp
    let retrievableBy: KeyPath<FavColor, String> = \FavColor.id
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FavColor, rhs: FavColor) -> Bool {
        lhs.color == rhs.color && lhs.name == rhs.name
    }
    
    enum CodingKeys: String, CodingKey {
        case color
        case name
        case id
        case timeStamp
    }
    
    init(color: Color.Values, name: String?) {
        self.color = color
        self.name = name
    }
    
    init(color: Color.Values, name: String?, id: String, timeStamp: TimeInterval) {
        self.color = color
        self.name = name
        self.id = id
        self.timeStamp = timeStamp
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.color = try values.decode(Color.Values.self, forKey: .color)
        self.name = try values.decode(Optional<String>.self, forKey: .name)
        self.id = try values.decode(String.self, forKey: .id)
        self.timeStamp = try values.decode(TimeInterval.self, forKey: .timeStamp)
    }
    
}
