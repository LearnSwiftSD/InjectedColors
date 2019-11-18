//
//  Color.swift
//  InjectedColors
//
//  Created by Stephen Martinez on 11/17/19.
//  Copyright © 2019 Stephen Martinez. All rights reserved.
//

import Foundation

struct Color {
    
    static func toHex(colorValue: Int) -> String {
        hexConvert(colorValue)
    }
    
    static func toDecimal(colorValue: Float) -> Int {
        Int(colorValue * 255)
    }
    
    static func toFloat(colorValue: Int) -> Float {
        Float(colorValue) / 255
    }
    
    private static func hexConvert(_ num: Int) -> String {
        String(format:"%02X" ,num)
    }
    
}

extension Color {
    
    /// A simple struct for passing Color Values around
    struct Values: Equatable, Codable {

        @Clamping var red: Int
        @Clamping var green: Int
        @Clamping var blue: Int
        
        enum CodingKeys: String, CodingKey {
            case red
            case green
            case blue
        }
        
        init(red: Int, green: Int, blue: Int) {
            self._red = Clamping(wrappedValue: red, 0...255)
            self._green = Clamping(wrappedValue: green, 0...255)
            self._blue = Clamping(wrappedValue: blue, 0...255)
        }

        init(red: Float, green: Float, blue: Float) {
            self._red = Clamping(wrappedValue: toDecimal(colorValue: red), 0...255)
            self._green = Clamping(wrappedValue: toDecimal(colorValue: green), 0...255)
            self._blue = Clamping(wrappedValue: toDecimal(colorValue: blue), 0...255)
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let decodedRed = try values.decode(Int.self, forKey: .red)
            let decodedGreen = try values.decode(Int.self, forKey: .green)
            let decodedBlue = try values.decode(Int.self, forKey: .blue)
            self._red = Clamping(wrappedValue: decodedRed, 0...255)
            self._green = Clamping(wrappedValue: decodedGreen, 0...255)
            self._blue = Clamping(wrappedValue: decodedBlue, 0...255)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(red, forKey: .red)
            try container.encode(green, forKey: .green)
            try container.encode(blue, forKey: .blue)
        }
        
        var float: FloatValues {
            return FloatValues(
                red: toFloat(colorValue: red),
                green: toFloat(colorValue: green),
                blue: toFloat(colorValue: blue)
            )
        }
        
        var hex: String {
            let hexR = toHex(colorValue: red)
            let hexG = toHex(colorValue: green)
            let hexB = toHex(colorValue: blue)
            return hexR + hexG + hexB
        }
        
        static func == (lhs: Color.Values, rhs: Color.Values) -> Bool {
            lhs.red == rhs.red && lhs.green == rhs.green && lhs.blue == rhs.blue
        }
        
    }
    
}

extension Color.Values {
    
    struct FloatValues {
        @UnitInterval var red: Float
        @UnitInterval var green: Float
        @UnitInterval var blue: Float
    }
    
}
