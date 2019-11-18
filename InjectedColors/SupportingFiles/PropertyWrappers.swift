//
//  PropertyWrappers.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation

@propertyWrapper
struct Clamping<Value: Comparable> {
    
    var value: Value
    let range: ClosedRange<Value>
    
    init(wrappedValue value: Value, _ range: ClosedRange<Value>) {
        self.value = Self.assign(value, using: range)
        self.range = range
    }

    var wrappedValue: Value {
        get { value }
        set { value = Self.assign(newValue, using: range) }
    }
    
    private static func assign(_ newValue: Value, using agreedRange: ClosedRange<Value>) -> Value {
        return min(max(agreedRange.lowerBound, newValue), agreedRange.upperBound)
    }
    
}

@propertyWrapper
struct UnitInterval<Value: FloatingPoint> {
    
    @Clamping var wrappedValue: Value

    init(wrappedValue value: Value) {
        self._wrappedValue = Clamping(wrappedValue: value, 0...1)
    }
    
}
