//
//  ColorStoreTstDbl.swift
//  InjectedColorsTests
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation
import Combine

final class ColorStoreTstDbl: ColorStoreService {
    
    private var storageContainer = [String: FavColor]()
    
    private let _didSave = PassthroughSubject<[FavColor], Never>()
    private let _didUpdate = PassthroughSubject<[FavColor], Never>()
    private let _didDelete = PassthroughSubject<[FavColor], Never>()
    
    private init() { }
    
    static let shared = ColorStoreTstDbl()
    
    static func load(data: [String: FavColor]) {
        shared.storageContainer = data
    }
    
    var all: [FavColor] {
        storageContainer
            .map { $0.value }
            .sorted(by: { $0[keyPath: $0.sortPath] > $1[keyPath: $1.sortPath] })
    }
    
    var didSave: AnyPublisher<[FavColor], Never> {
        _didSave.eraseToAnyPublisher()
    }
    
    var didUpdate: AnyPublisher<[FavColor], Never> {
        _didUpdate.eraseToAnyPublisher()
    }
    
    var didDelete: AnyPublisher<[FavColor], Never> {
        _didDelete.eraseToAnyPublisher()
    }
    
    func save(_ storable: FavColor) {
        storageContainer[storable.id] = storable
        _didSave.send([storable])
    }
    
    func update(_ storable: FavColor) {
        let found = storageContainer[storable.id]
        assert(found != nil, "Tried to update something not stored")
        storageContainer[storable.id] = storable
        _didUpdate.send(all)
    }
    
    func delete(_ storable: FavColor) {
        let found = storageContainer.removeValue(forKey: storable.id)
        assert(found != nil, "Tried to delete something not stored")
        _didDelete.send([storable])
    }
    
}
