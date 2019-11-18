//
//  ColorViewModelTstDbl.swift
//  InjectedColorsTests
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Injectable
import UIKit

final class ColorViewModelTstDbl: ColorViewModel {
    
    @Injected var colorStore: ColorStoreService
    
    var existingFav: FavColor?
    
    private var cancellables = Cancellables()
    let textFieldHandler = TextFieldHandler()
    
    //MARK: - Testing Inputs
    private var redSlider = CurrentValueSubject<Float, Never>(0)
    private var greenSlider = CurrentValueSubject<Float, Never>(0)
    private var blueSlider = CurrentValueSubject<Float, Never>(0)
    
    //MARK: - Current Color State Used for Saving
    
    //`colorValues` will be useed as a testing input as well
    private lazy var colorValues: CurrentValueSubject<Color.Values, Never> = {
        guard let existingFav = existingFav else {
            let value = Color.Values(red: 0, green: 0, blue: 0)
            return CurrentValueSubject<Color.Values, Never>(value)
        }
        return CurrentValueSubject<Color.Values, Never>(existingFav.color)
    }()
    
    private lazy var colorName = CurrentValueSubject<String, Never>(existingFav?.name ?? "")
    
    //MARK: - Keyboard Publishers
    var keyboardWillShowPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: TestNotifications.keyBoardWillShow)
            .eraseToAnyPublisher()
    }
    
    var keyboardWillHidePublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: TestNotifications.keyBoardWillHide)
            .eraseToAnyPublisher()
    }
    
    
    var didChangeColor: (Color.Values) -> Void {
        return { [weak self] values in
            guard let self = self else { return }
            self.colorValues.send(values)
        }
    }
    
    //MARK: - Consumed By TextField Publisher
    var didChangeName: (String) -> Void {
        return { [weak self] value in
            guard let self = self else { return }
            self.colorName.send(value)
        }
    }
    
    func assignColor(_ favColor: FavColor) {
        existingFav = favColor
    }
    
    func didFinishBinding() {
        
    }
    
    func moveSlider(_ slider: SliderSelection) {
        func convert(_ position: Int) -> Float {
            let clampedValue = min(max(0, position), 255)
            return Color.toFloat(colorValue: clampedValue)
        }
        switch slider {
        case .red(let position):
            redSlider.send(convert(position))
        case .green(let position):
            greenSlider.send(convert(position))
        case .blue(let position):
            blueSlider.send(convert(position))
        }
    }
    
    func enterText(entry: TextEntry) {
        switch entry {
        case .begin:
            NotificationCenter.default.post(name: TestNotifications.keyBoardWillShow, object: nil)
        case .done:
            NotificationCenter.default.post(name: TestNotifications.keyBoardWillHide, object: nil)
        case .edit(text: let text):
            let currentText = colorName.value
            let newText = currentText + text
            didChangeName(newText)
        case .delete:
            didChangeName("")
        }
    }
    
    func redPublisher(for slider: UISlider) -> SharedPublisher<Float, Never> {
        return redSlider
            .prepend(existingFav?.color.float.red ?? 0.0)
            .removeDuplicates()
            .eraseToAnyPublisher()
            .share()
    }
    
    func greenPublisher(for slider: UISlider) -> SharedPublisher<Float, Never> {
        return greenSlider
            .prepend(existingFav?.color.float.green ?? 0.0)
            .removeDuplicates()
            .eraseToAnyPublisher()
            .share()
    }
    
    func bluePublisher(for slider: UISlider) -> SharedPublisher<Float, Never> {
        return blueSlider
            .prepend(existingFav?.color.float.blue ?? 0.0)
            .removeDuplicates()
            .eraseToAnyPublisher()
            .share()
    }
    
    func slidersPublisher(for sliders: ColorViewSliders) -> SharedPublisher<Color.Values, Never> {
        
        Publishers.CombineLatest3(
            redPublisher(for: sliders.red),
            greenPublisher(for: sliders.green),
            bluePublisher(for: sliders.blue)
        )
        .map(Color.Values.init)
        .supply(to: didChangeColor)
        .store(in: &cancellables)
        
        return colorValues
            .eraseToAnyPublisher()
            .share()
    }
    
    func didSaveColor() {
        let color = FavColor(color: colorValues.value, name: colorName.value)
        colorStore.save(color)
    }
    
    func didEditColor() {
        guard var newFav = existingFav else { return }
        newFav.color = colorValues.value
        newFav.name = colorName.value
        colorStore.update(newFav)
    }
    
    func didDeleteColor() {
        guard let existingFav = existingFav else { return }
        colorStore.delete(existingFav)
    }
    
    var inputs: ColorViewModelInputs { self as ColorViewModelInputs }
    
    deinit { print("👋 Goodbye") }
    
}

extension ColorViewModelTstDbl: ColorViewModelInputs {
    
    var currentName: String { colorName.value }
    
}

protocol ColorViewModelInputs {
    
    func moveSlider(_ slider: SliderSelection) -> Void

    func enterText(entry: TextEntry) -> Void

    var currentName: String { get }
}

enum TextEntry {
    case begin
    case done
    case edit(text: String)
    case delete
}

struct TestNotifications {
    static let keyBoardWillShow = NSNotification.Name(
        rawValue: "Test_KeyBoardWillShow")
    static let keyBoardWillHide = NSNotification.Name(
        rawValue: "Test_KeyBoardWillHide")
}

enum SliderSelection {
    case red(toPosition: Int)
    case green(toPosition: Int)
    case blue(toPosition: Int)
}

class ColorViewModelMatcher {
    
    var colorValues: Color.Values
    var name: String?
    var red: Int { colorValues.red }
    var green: Int { colorValues.green }
    var blue: Int { colorValues.blue }
    
    init(_ favColor: FavColor?) {
        self.colorValues = favColor?.color ?? Color.Values.empty
        self.name = favColor?.name
    }
    
    init(color: Color.Values, name: String?) {
        self.colorValues = color
        self.name = name
    }
    
    func redInput(_ value: Int) {
        colorValues.red = value
    }
    
    func greenInput(_ value: Int) {
        colorValues.green = value
    }
    
    func blueInput(_ value: Int) {
        colorValues.blue = value
    }
    
    func colorInput(_ value: Color.Values) {
        colorValues = value
    }
    
    func textInput(_ value: String?) {
        name = value
    }
    
}
