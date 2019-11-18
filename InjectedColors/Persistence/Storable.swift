//
//  Storable.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation
import Combine
import RealmSwift

typealias Storable = Hashable & Codable & Projectable

protocol Projectable {

    associatedtype EntityType: StorableProjecting

    associatedtype SortingType: Comparable
    
    associatedtype Identifier: Hashable
    
    var sortPath: KeyPath<Self, SortingType> { get }
    
    var retrievableBy: KeyPath<Self, Identifier> { get }
    
}

protocol StorableProjecting: Object {
    
    associatedtype ProjectedStorable: Projectable
    
    func projection() -> ProjectedStorable
    
    static func get(with storable: ProjectedStorable) -> Self
    
}

struct Store<T: Storable> { }

struct PersistenceAdapter<T: Storable> where T.EntityType.ProjectedStorable == T {
    
    private let realm: Realm
    
    init() { self.realm = Realm.required }
    
    var all: [T] {
        get { realm.objects(T.EntityType.self)
            .map { $0.projection() }
            .sorted(by: { $0[keyPath: $0.sortPath] > $1[keyPath: $1.sortPath] })
        }
    }
    
    func save(_ storable: T) {
        let entity = T.EntityType.get(with: storable)
        realm.save(entity)
    }
    
    func update(_ storable: T) {
        let entity = T.EntityType.get(with: storable)
        realm.save(entity)
    }
    
    func delete(_ storable: T) {
        let entity = realm.object(ofType: T.EntityType.self,
                                  forPrimaryKey: storable[keyPath: storable.retrievableBy]
        )
        entity.map { realm.remove($0) }
    }
    
}
