import Foundation

/// Gets Source Code Location Data
public struct LocData {
    
    public let object: String
    public let file: String
    public let function: String
    public let line: String
    
    public init(_ object: Any, file: String = #file, function: String = #function, line: UInt = #line) {
        self.object = "\(type(of: object))"
        self.file = file
        self.function = function
        self.line = "line: \(line)"
    }
    
}
