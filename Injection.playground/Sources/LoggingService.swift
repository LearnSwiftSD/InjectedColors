import Foundation

public protocol LoggingService {
    
    func info(tag: String?, message: String, loc: LocData)
    func debug(tag: String?, message: String, loc: LocData)
    func error(tag: String?, message: String, loc: LocData)
    
}
