//
//  ColorStoreService.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Foundation
import Injectable

protocol ColorStoreService: InjectableService {
    
    var all: [FavColor] { get }
    
    var didSave: AnyPublisher<[FavColor], Never> { get }
    
    var didUpdate: AnyPublisher<[FavColor], Never> { get }
    
    var didDelete: AnyPublisher<[FavColor], Never> { get }
    
    func save(_ storable: FavColor)
    
    func update(_ storable: FavColor)
    
    func delete(_ storable: FavColor)
    
}

fileprivate final class ColorStorageContainer {
    
    static let shared = ColorStorageContainer()
    let didSave = PassthroughSubject<[FavColor], Never>()
    let didUpdate = PassthroughSubject<[FavColor], Never>()
    let didDelete = PassthroughSubject<[FavColor], Never>()
    let adapter = PersistenceAdapter<FavColor>()
    
    private init() {}
}

extension Store: InjectableService where T == FavColor { }

extension Store: ColorStoreService where T == FavColor {
    
    private var storageContainer: ColorStorageContainer {
        return ColorStorageContainer.shared
    }
    
    var all: [T] { storageContainer.adapter.all }
    
    var didSave: AnyPublisher<[T], Never> {
        storageContainer.didSave.eraseToAnyPublisher()
    }
    
    var didUpdate: AnyPublisher<[T], Never> {
        storageContainer.didUpdate.eraseToAnyPublisher()
    }
    
    var didDelete: AnyPublisher<[T], Never> {
        storageContainer.didDelete.eraseToAnyPublisher()
    }
    
    func save(_ storable: T) {
        storageContainer.adapter.save(storable)
        storageContainer.didSave.send([storable])
    }
    
    func update(_ storable: T) {
        storageContainer.adapter.update(storable)
        storageContainer.didUpdate.send(all)
    }
    
    func delete(_ storable: T) {
        storageContainer.adapter.delete(storable)
        storageContainer.didDelete.send([storable])
    }
    
}
