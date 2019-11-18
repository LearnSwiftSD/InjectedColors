//
//  ColorStoreServiceTests.swift
//  InjectedColorsTests
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Injectable
import XCTest

class ColorStoreServiceTests: XCTestCase {

    @Injected private var colorStore: ColorStoreService
    
    override func setUp() {
        super.setUp()
        // Register the test mock for the service
        InjectableServices.register(service: ColorStoreService.self, ColorStoreTstDbl.shared)
        logSetup()
    }

    override func tearDown() {
        super.tearDown()
        ColorStoreTstDbl.load(data: ColorStoreData.emptyStorage)
        logTearDown()
    }
    
    func test_EmptyColorStore() {
        // Empty the Color Store
        ColorStoreTstDbl.load(data: ColorStoreData.emptyStorage)
        XCTAssert(colorStore.all == [], "ColorStore should be empty")
    }
 
    func test_SaveOneColorToStore() {
        ColorStoreTstDbl.load(data: ColorStoreData.emptyStorage)
        let colorToSave = ColorStoreData.randomSingle
        colorStore.save(colorToSave)
        
        guard let color = colorStore.all.first else {
            XCTFail("Should have at least one color. None were found!")
            return
        }
        
        XCTAssertEqual(colorStore.all.count, 1, "A Different amount of colors have been saved")
        XCTAssertEqual(color.id, colorToSave.id, "Color that was saved is different than one found")
    }
    
    func test_DeleteOneColorFromStore() {
        
        let singleStorage = ColorStoreData.randomSingleStorage
        ColorStoreTstDbl.load(data: singleStorage)
        
        guard let colorToDelete = singleStorage.first?.value else {
            fatalError("Test data inconsistency! There was supposed to be one value supplied!")
        }
        
        colorStore.delete(colorToDelete)
        
        XCTAssertEqual(colorStore.all.count, 0, "The single color should have been deleted")
    }
    
    func test_UpdateOneColorInStore() {
        
        let singleStorage = ColorStoreData.randomSingleStorage
        ColorStoreTstDbl.load(data: singleStorage)
        
        guard let colorToUpdate = singleStorage.first?.value else {
            fatalError("Test data inconsistency! There was supposed to be one value supplied!")
        }
        
        let newName = "I've Been Changed!"
        
        let updatedColor: FavColor = {
            var newColor = colorToUpdate
            newColor.name = newName
            return newColor
        }()
        
        colorStore.update(updatedColor)
        
        guard let retrievedUpdatedColor = colorStore.all.first else {
            XCTFail("Should have at least one color. None were found!")
            return
        }
        
        XCTAssertEqual(colorStore.all.count, 1, "Shouldn't change the amount of values in store")
        XCTAssertNotEqual(colorToUpdate, retrievedUpdatedColor, "Should be different than the original")
        XCTAssertEqual(updatedColor, retrievedUpdatedColor, "Should be the same as the one stored")
    }
    
    func test_SaveTriggersPublisher() {
        ColorStoreTstDbl.load(data: ColorStoreData.emptyStorage)
        let colorToSave = ColorStoreData.randomSingle
        
        // Setup the expectations
        let expectSavedColorsToBeSent = expectation(description: "Saved Colors Sent")
        let allExpectations = [expectSavedColorsToBeSent]
        
        // Setup Save Publisher
        var savedColorsSent: [FavColor]?
        
        let saveCancellable = colorStore.didSave
            .sink {
                savedColorsSent = $0
                expectSavedColorsToBeSent.fulfill()
        }
        
        // Apply the save action
        colorStore.save(colorToSave)
        
        // Wait for Async code and then assert
        wait(for: allExpectations, timeout: 1)
        
        XCTAssertNotNil(savedColorsSent, "Did Save should have passed a value to this")
        XCTAssertEqual(savedColorsSent, [colorToSave], "Should be the same")
        saveCancellable.cancel()
    }
    
    func test_DeleteTriggersPublisher() {
        let singleStorage = ColorStoreData.randomSingleStorage
        ColorStoreTstDbl.load(data: singleStorage)
        
        guard let colorToDelete = singleStorage.first?.value else {
            fatalError("Test data inconsistency! There was supposed to be one value supplied!")
        }
        
        // Setup the expectations
        let expectDeletedColorsToBeSent = expectation(description: "Deleted Colors Sent")
        let allExpectations = [expectDeletedColorsToBeSent]
        
        // Setup Save Publisher
        var deletedColorsSent: [FavColor]?
        
        let deleteCancellable = colorStore.didDelete
            .sink {
                deletedColorsSent = $0
                expectDeletedColorsToBeSent.fulfill()
        }
        
        // Apply the delete action
        colorStore.delete(colorToDelete)
        
        // Wait for Async code and then assert
        wait(for: allExpectations, timeout: 1)
        
        XCTAssertNotNil(deletedColorsSent, "Did Delete should have passed a value to this")
        XCTAssertEqual(deletedColorsSent, [colorToDelete], "Should be the same")
        XCTAssertEqual(colorStore.all, [], "Should be empty")
        deleteCancellable.cancel()
    }
    
    func test_UpdateTriggersPublisher() {
        
        let singleStorage = ColorStoreData.randomSingleStorage
        ColorStoreTstDbl.load(data: singleStorage)
        
        guard let colorToUpdate = singleStorage.first?.value else {
            fatalError("Test data inconsistency! There was supposed to be one value supplied!")
        }
        
        let newName = "I've Been Changed!"
        
        let updatedColor: FavColor = {
            var newColor = colorToUpdate
            newColor.name = newName
            return newColor
        }()
        
        // Setup the expectations
        let expectUpdatedColorsToBeSent = expectation(description: "Updated Colors Sent")
        let allExpectations = [expectUpdatedColorsToBeSent]
        
        // Setup Update Publisher
        var updatedColorsSent: [FavColor]?
        
        let updateCancellable = colorStore.didUpdate
            .sink {
                updatedColorsSent = $0
                expectUpdatedColorsToBeSent.fulfill()
        }
        
        // Apply the update action
        colorStore.update(updatedColor)
        
        // Wait for Async code and then assert
        wait(for: allExpectations, timeout: 1)
        
        XCTAssertNotNil(updatedColorsSent, "Did Update should have passed a value to this")
        XCTAssertEqual(updatedColorsSent, colorStore.all, "Should be the same")
        XCTAssertTrue(colorStore.all.contains(updatedColor), "Should contain the updated color")
        updateCancellable.cancel()
    }
    
}
