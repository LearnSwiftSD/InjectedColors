//
//  RealmExtensions.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Realm
import RealmSwift

extension Realm {
    
    func safeWrite(_ block: (() throws -> Void)) throws {
        if isInWriteTransaction {
            try block()
        } else {
            try write(block)
        }
    }
    
    /// Opens and returns a default realm instance.
    static var required: Realm {
        let realm = try? Realm()
        precondition(realm != nil, "Unable to open a realm instance")
        return realm!
    }
    
    static var open: Realm? {
        return try? Realm()
    }
    
    static func emptyResults<T: Object>(for type: T.Type) -> Results<T> {
        let realm = Realm.required
        return realm.objects(type.self).filter("DONTGETANYRESULTS")
    }
    
    func save(_ entities: [Object]) {
        do {
            guard !self.isInWriteTransaction else { return }
            try self.safeWrite { entities.forEach { self.add($0, update: .all) } }
        } catch let error {
            dump(entities)
            dump(error)
            return
        }
        
    }
    
    func save(_ entity: Object) {
        save([entity])
    }
    
    func remove(_ entities: [Object]) {
        do {
            guard !self.isInWriteTransaction else { return }
            try self.safeWrite { self.delete(entities) }
        } catch let error {
            dump(entities)
            dump(error)
            return
        }
        
    }
    
    func remove(_ entity: Object) {
        remove([entity])
    }
    
}
