//
//  ColorViewModel.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Combine
import Injectable
import UIKit

protocol ColorViewModel {
    
    var colorStore: ColorStoreService { get }
    var existingFav: FavColor? { get set }
    var textFieldHandler: TextFieldHandler { get }
    
    var keyboardWillShowPublisher: AnyPublisher<Notification, Never> { get }
    var keyboardWillHidePublisher: AnyPublisher<Notification, Never> { get }
    var didChangeColor: (Color.Values) -> Void { get }
    var didChangeName: (String) -> Void { get }
    
    func assignColor(_ favColor: FavColor) -> Void
    func didFinishBinding() -> Void
    
    func redPublisher(for slider: UISlider) -> SharedPublisher<Float, Never>
    func greenPublisher(for slider: UISlider) -> SharedPublisher<Float, Never>
    func bluePublisher(for slider: UISlider) -> SharedPublisher<Float, Never>
    
    func slidersPublisher(for sliders: ColorViewSliders) -> SharedPublisher<Color.Values, Never>
    
    func didSaveColor() -> Void
    func didEditColor() -> Void
    func didDeleteColor() -> Void
}

class ColorViewModelImpl: ColorViewModel {
    
    @Injected var colorStore: ColorStoreService
    var existingFav: FavColor?
    
    private var redSliderPublisher: SharedPublisher<Float, Never>?
    private var greenSliderPublisher: SharedPublisher<Float, Never>?
    private var blueSliderPublisher: SharedPublisher<Float, Never>?
    private var allSlidersPublisher: SharedPublisher<Color.Values, Never>?
    private var cancellables = Cancellables()
    
    let textFieldHandler = TextFieldHandler()
    
    private lazy var colorValues: CurrentValueSubject<Color.Values, Never> = {
        guard let existingFav = existingFav else {
            let value = Color.Values(red: 0, green: 0, blue: 0)
            return CurrentValueSubject<Color.Values, Never>(value)
        }
        return CurrentValueSubject<Color.Values, Never>(existingFav.color)
    }()
    
    private lazy var colorName = CurrentValueSubject<String, Never>(existingFav?.name ?? "")
    
    var keyboardWillShowPublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .print("keyboardWillShow")
            .eraseToAnyPublisher()
    }
    
    var keyboardWillHidePublisher: AnyPublisher<Notification, Never> {
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .print("keyboardWillHide")
            .eraseToAnyPublisher()
    }
    
    var didChangeColor: (Color.Values) -> Void {
        return { [weak self] values in
            guard let self = self else { return }
            self.colorValues.send(values)
        }
    }
    
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
        
        colorValues
            .print("Color Values")
            .sink { _ in }
            .store(in: &cancellables)
        
        colorName
            .print("Color Name")
            .sink { _ in }
            .store(in: &cancellables)
    }
    
    func redPublisher(for slider: UISlider) -> SharedPublisher<Float, Never> {
        
        guard let redPublisher = redSliderPublisher else {
            let newPublisher = slider.publisher(for: .valueChanged)
            .map { $0.value }
            .prepend(existingFav?.color.float.red ?? 0.0)
            .removeDuplicates()
            .eraseToAnyPublisher()
            .share()
            
            redSliderPublisher = newPublisher
            return newPublisher
        }
        
        return redPublisher
    }
    
    func greenPublisher(for slider: UISlider) -> SharedPublisher<Float, Never> {
        
        guard let greenPublisher = greenSliderPublisher else {
            let newPublisher = slider.publisher(for: .valueChanged)
            .map { $0.value }
            .prepend(existingFav?.color.float.green ?? 0.0)
            .removeDuplicates()
            .eraseToAnyPublisher()
            .share()
            
            greenSliderPublisher = newPublisher
            return newPublisher
        }
        
        return greenPublisher
    }
    
    func bluePublisher(for slider: UISlider) -> SharedPublisher<Float, Never> {
        
        guard let bluePublisher = blueSliderPublisher else {
            let newPublisher = slider.publisher(for: .valueChanged)
            .map { $0.value }
            .prepend(existingFav?.color.float.blue ?? 0.0)
            .removeDuplicates()
            .eraseToAnyPublisher()
            .share()
            
            blueSliderPublisher = newPublisher
            return newPublisher
        }
        
        return bluePublisher
    }
    
    func slidersPublisher(for sliders: ColorViewSliders) -> SharedPublisher<Color.Values, Never> {
        
        guard let slidersPublisher = allSlidersPublisher else {
            let newPublisher = Publishers.CombineLatest3(
                redPublisher(for: sliders.red),
                greenPublisher(for: sliders.green),
                bluePublisher(for: sliders.blue)
            )
            .map(Color.Values.init)
            .eraseToAnyPublisher()
            .share()
            
            allSlidersPublisher = newPublisher
            return newPublisher
        }
        
        return slidersPublisher
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
    
    deinit { print("👋 Goodbye") }
    
}

struct ColorViewSliders {
    let red: UISlider
    let green: UISlider
    let blue: UISlider
}
