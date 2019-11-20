import Foundation

public typealias ServiceIdentifier = ObjectIdentifier

/// Produces a unique identifier for the type
public func identifier<T>(for: T.Type) -> ServiceIdentifier {
    ServiceIdentifier(T.self)
}

/// Identifies if the type is a protocol
public func isProtocol<T>(type protocolType: T.Type) -> Bool {
    let typeDescription = String(describing: type(of: protocolType.self))
    let protocolIdentifier = ".Protocol"
    return typeDescription.hasSuffix(protocolIdentifier)
}
