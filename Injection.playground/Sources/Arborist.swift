import Foundation

public class Arborist {
    
    private let infoTag = "🌲🌲🌲"
    private let debugTag = "🍃🍃🍃"
    private let errorTag = "🔥 🔥🔥 🔥"
    private let spacer = " | "
    
    public init() {}
    
    private func wrap(message: String, with tag: String) -> String {
        return tag + " " + message + " " + tag
    }
    
    private func logMessage(tag: String?, message: String, loc: LocData) -> String {
        let tagSection = tag.flatMap { "* " + $0 + " *" + spacer } ?? ""
        return tagSection
            + loc.file
            + spacer
            + loc.object
            + spacer
            + loc.function
            + spacer
            + loc.line
            + spacer
            + message
    }
    
    public func info(tag: String?, message: String, loc: LocData) {
        let loggedMessage = logMessage(tag: tag, message: message, loc: loc)
        let wrappedMessage = wrap(message: loggedMessage, with: infoTag)
        print(wrappedMessage)
    }
    
    public func debug(tag: String?, message: String, loc: LocData) {
        let loggedMessage = logMessage(tag: tag, message: message, loc: loc)
        let wrappedMessage = wrap(message: loggedMessage, with: debugTag)
        print(wrappedMessage)
    }
    
    public func error(tag: String?, message: String, loc: LocData) {
        let loggedMessage = logMessage(tag: tag, message: message, loc: loc)
        let wrappedMessage = wrap(message: loggedMessage, with: errorTag)
        print(wrappedMessage)
    }
    
    deinit {
        print("Arborist deinitialized 👋")
    }
    
}
