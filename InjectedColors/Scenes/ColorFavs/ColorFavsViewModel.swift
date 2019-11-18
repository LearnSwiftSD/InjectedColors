//
//  ColorFavsViewModel.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Injectable
import UIKit

protocol ColorFavsViewModel {
    
    var colorStore: ColorStoreService { get }
    
    var dataSource: UITableViewDiffableDataSource<DefaultSection, FavColor>? { get }
    
    func configureDataSource(with tableView: UITableView) -> Void
    
}

class ColorFavsViewModelImpl: ColorFavsViewModel {

    @Injected var colorStore: ColorStoreService
    
    private(set) var dataSource: UITableViewDiffableDataSource<DefaultSection, FavColor>?
    
    private var cancellables = Cancellables()
    
    // MARK: - Create a Cell Provider `colorFavCell`
    private var colorFavCell: (UITableView, IndexPath, FavColor) -> UITableViewCell? {
        return { tableView, indexPath, favColor in
            let cFavCell = ColorFavCell.create()
            cFavCell.colorView.shiftTo(favColor.color)
            cFavCell.nameLabel.text = favColor.name
            cFavCell.hexLabel.text = favColor.color.hex
            return cFavCell
        }
    }
    
    // MARK: - Assign/Create The Diffable DataSource `dataSource`
    func configureDataSource(with tableView: UITableView) {
        dataSource = UITableViewDiffableDataSource<DefaultSection, FavColor>(
            tableView: tableView,
            cellProvider: colorFavCell
        )
        // Apply the initial snapshot
        dataSource?.apply(colorFavSnapshot(colorStore.all), animatingDifferences: false)
        setUpPersistenceActions()
    }
    
    // MARK: - Create a snapshot provider `colorFavSnapshot`
    private func colorFavSnapshot(_ newColors: [FavColor]) -> NSDiffableDataSourceSnapshot<DefaultSection, FavColor> {
        var snapshot = NSDiffableDataSourceSnapshot<DefaultSection, FavColor>()
        snapshot.appendSections([.main])
        snapshot.appendItems(newColors)
        return snapshot
    }
    
    // MARK: - Persistence Actions / update with Snapshot updates
    private var saveAction: ([FavColor]) -> Void {
        return { [weak self] in
            guard let self = self, let dataSource = self.dataSource else { return }
            var snapshot = dataSource.snapshot()
            guard let first = snapshot.itemIdentifiers.first else {
                snapshot.appendItems($0)
                dataSource.apply(snapshot)
                return
            }
            snapshot.insertItems($0, beforeItem: first)
            dataSource.apply(snapshot)
        }
    }
    
    private var editAction: ([FavColor]) -> Void {
        return { [weak self] in
            guard let self = self, let dataSource = self.dataSource else { return }
            let snapshot = self.colorFavSnapshot($0)
            dataSource.apply(snapshot)
        }
    }
    
    private var deleteAction: ([FavColor]) -> Void {
        return { [weak self] in
            guard let self = self, let dataSource = self.dataSource else { return }
            var snapshot = dataSource.snapshot()
            snapshot.deleteItems($0)
            dataSource.apply(snapshot)
        }
    }
    
    private func setUpPersistenceActions() {
        colorStore.didSave
            .print("DidSave")
            .supply(to: saveAction)
            .store(in: &cancellables)
        
        colorStore.didUpdate
            .print("DidUpdate")
            .supply(to: editAction)
            .store(in: &cancellables)
        
        colorStore.didDelete
            .print("DidDelete")
            .supply(to: deleteAction)
            .store(in: &cancellables)
    }
    
}

// MARK: - Create DiffableDataSource TableView Sections
enum DefaultSection { case main }
