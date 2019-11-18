//
//  ColorViewModelTests.swift
//  InjectedColorsTests
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Injectable
import UIKit
import XCTest

class ColorViewModelTests: XCTestCase {

    @ScopedInjection var colorViewModel: ColorViewModel
    
    var inputs: ColorViewModelInputs {
        guard let colorVM = colorViewModel as? ColorViewModelTstDbl else {
            XCTFail("ColorViewModelTstDbl was not used!")
            return ColorViewModelTstDbl().inputs
        }
        return colorVM.inputs
    }
    
    override func setUp() {
        super.setUp()
        InjectableServices.register(service: ColorViewModel.self, ColorViewModelTstDbl())
        InjectableServices.register(service: ColorStoreService.self, ColorStoreTstDbl.shared)
        logSetup()
    }

    override func tearDown() {
        super.tearDown()
        ColorStoreTstDbl.load(data: ColorStoreData.emptyStorage)
        logTearDown()
    }

    func bindViewModelTo(_ matcher: ColorViewModelMatcher) -> Cancellables {
        let sliders = ColorViewSliders.empty
        var cancellables = Cancellables()
        
        // Bind the publishers to the matcher
        colorViewModel
            .slidersPublisher(for: sliders)
            .supply(to: matcher.colorInput)
            .store(in: &cancellables)
               
        colorViewModel
            .redPublisher(for: sliders.red)
            .map(Color.toDecimal)
            .supply(to: matcher.redInput)
            .store(in: &cancellables)
        
        colorViewModel
            .greenPublisher(for: sliders.green)
            .map(Color.toDecimal)
            .supply(to: matcher.greenInput)
            .store(in: &cancellables)
        
        colorViewModel
            .bluePublisher(for: sliders.blue)
            .map(Color.toDecimal)
            .supply(to: matcher.blueInput)
            .store(in: &cancellables)
               
        colorViewModel
            .keyboardWillShowPublisher
            .supply { _ in }
            .store(in: &cancellables)
        
        colorViewModel
            .keyboardWillHidePublisher
            .supply { _ in }
            .store(in: &cancellables)
               
        colorViewModel.didFinishBinding()
        
        return cancellables
    }
    
    func test_makeAWhiteColor() {
        
        // Ensures that the Color View Model is torn down at the end of scope
        defer { InjectableServices.token(for: ColorViewModel.self).removeService() }
        
        // Setup values
        let expectedColor = Color.Values(red: 250, green: 250, blue: 255)
        let expectedName = "White Shadow"
        
        // Setup Matchers
        let expectedValue = ColorViewModelMatcher(color: expectedColor, name: expectedName)
        let matcher = ColorViewModelMatcher(colorViewModel.existingFav)
        
        // Setup keyboard expectations
        let expectKeyboardToShow = expectation(TestNotifications.keyBoardWillShow)
        let expectKeyboardToHide = expectation(TestNotifications.keyBoardWillHide)
        let keyboardExpectations = [expectKeyboardToShow, expectKeyboardToHide]
        
        // Bind the view model to the matcher
        let cancellables = bindViewModelTo(matcher)
        print("Subscription Count: ", cancellables.count)
        
        // Start inputing test values
        inputs.moveSlider(.red(toPosition: 250))
        
        inputs.moveSlider(.green(toPosition: 251))
        inputs.moveSlider(.green(toPosition: 252))
        
        inputs.moveSlider(.blue(toPosition: 256))
        inputs.moveSlider(.blue(toPosition: 254))
        inputs.moveSlider(.blue(toPosition: 255))
        
        inputs.moveSlider(.green(toPosition: 250))
        
        inputs.enterText(entry: .begin)
        inputs.enterText(entry: .edit(text: "White Shadow"))
        inputs.enterText(entry: .done)
        
        matcher.name = inputs.currentName
        
        // Wait for the expected flow to complete and assert the expected state
        wait(for: keyboardExpectations, timeout: 1)
        
        XCTAssertTrue(matcher.red == expectedValue.red, "Red value should be \(expectedValue.red)")
        XCTAssertTrue(matcher.green == expectedValue.green, "Green value should be \(expectedValue.green)")
        XCTAssertTrue(matcher.blue == expectedValue.blue, "Blue value should be \(expectedValue.blue)")
        XCTAssertTrue(matcher.name == expectedValue.name, "Name should be \(expectedValue.name ?? "Nil")")
    }
    
    func test_makeAGreenColor() {
        
        // Ensures that the Color View Model is torn down at the end of scope
        defer { InjectableServices.token(for: ColorViewModel.self).removeService() }
        
        // Setup values
        let expectedColor = Color.Values(red: 13, green: 255, blue: 20)
        let expectedName = "Frog Green"
        
        // Setup Matchers
        let expectedValue = ColorViewModelMatcher(color: expectedColor, name: expectedName)
        let matcher = ColorViewModelMatcher(colorViewModel.existingFav)
        
        // Setup keyboard expectations
        let expectKeyboardToShow = expectation(TestNotifications.keyBoardWillShow)
        let expectKeyboardToHide = expectation(TestNotifications.keyBoardWillHide)
        let keyboardExpectations = [expectKeyboardToShow, expectKeyboardToHide]
        
        // Bind the view model to the matcher
        let cancellables = bindViewModelTo(matcher)
        print("Subscription Count: ", cancellables.count)
        
        // Start inputing test values
        inputs.moveSlider(.red(toPosition: 13))
        
        inputs.moveSlider(.green(toPosition: 251))
        inputs.moveSlider(.green(toPosition: 252))
        
        inputs.moveSlider(.blue(toPosition: 256))
        inputs.moveSlider(.blue(toPosition: 254))
        inputs.moveSlider(.blue(toPosition: 20))
        
        inputs.moveSlider(.green(toPosition: 255))
        
        inputs.enterText(entry: .begin)
        inputs.enterText(entry: .edit(text: "Frog Shme"))
        inputs.enterText(entry: .delete)
        inputs.enterText(entry: .edit(text: "Frog Green"))
        inputs.enterText(entry: .done)
        
        matcher.name = inputs.currentName
        
        colorViewModel.didSaveColor()
        
        // Wait for the expected flow to complete and assert the expected state
        wait(for: keyboardExpectations, timeout: 1)
        
        XCTAssertTrue(matcher.red == expectedValue.red, "Red value should be \(expectedValue.red)")
        XCTAssertTrue(matcher.green == expectedValue.green, "Green value should be \(expectedValue.green)")
        XCTAssertTrue(matcher.blue == expectedValue.blue, "Blue value should be \(expectedValue.blue)")
        XCTAssertTrue(matcher.name == expectedValue.name, "Name should be \(expectedValue.name ?? "Nil")")
        
        XCTAssertTrue(colorViewModel.colorStore.all.count == 1, "Only Saved one color")
        XCTAssertTrue(colorViewModel.colorStore.all.first?.color == expectedValue.colorValues, "Saved color should be the same as the expected color")
        XCTAssertTrue(colorViewModel.colorStore.all.first?.name == expectedValue.name, "Saved name should be the same as the expected name")
    }
    
}

extension ColorViewSliders {
    
    static var empty: ColorViewSliders {
        ColorViewSliders(
            red: UISlider(),
            green: UISlider(),
            blue: UISlider()
        )
    }
    
}

extension Color.Values {
    
    static var empty: Color.Values { Color.Values(red: 0, green: 0, blue: 0) }
    
}

extension XCTestCase {
    
    func expectation(_ forNotification: NSNotification.Name) -> XCTestExpectation {
        expectation(forNotification: forNotification, object: nil, handler: nil)
    }
    
    func logSetup() {
        print("")
        print("  ▼ 🛠🛠🛠 Set up Done for \(String(describing: self)) 🛠🛠🛠 ▼")
    }
    
    func logTearDown() {
        print("  ▲ 🧹🧹🧹 Clean up Done for \(String(describing: self)) 🧹🧹🧹 ▲")
        print("")
    }
}
