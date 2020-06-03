import Foundation

/**
 Public interface for main OktaLogger instances
 */
@objc
public protocol OktaLoggerProtocol {
    
    /**
     Initialize a primary logger instance with a list of destinations. Destinations are immutable for thread safety.
     
     - Parameters:
        - destinations: List of OktaLoggerDestinations
     */
    init(destinations: [OktaLoggerDestinationProtocol])
    
    /**
    Logging super-method for all parameters
    
    - Parameters:
      - level: OktaLoggerLogLevel for this event
      - eventName: name for this event
      - message: message for this event (optional)
      - properties: key-value properties for this event (optional)
         */
    func log(level: OktaLoggerLogLevel,
             eventName: String,
             message: String?,
             properties: [AnyHashable: Any]?,
             file: String,
             line: NSNumber,
             funcName: String)
    
    /**
     Update the log level for one or all destinations
     
     - Parameters:
         - level: OktaLoggerLogLevel to set
         - identifiers: destination identifiers to be updated
     */
    func setLogLevel(level: OktaLoggerLogLevel, identifiers: [String])
    
    /**
     Convenience method for log(level: .debug, ...)
     */
    func debug(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String)
    
    /**
     Convenience method for log(level: .info, ...)
     */
    func info(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String)
    
    /**
     Convenience method for log(level: .warning, ...)
     */
    func warning(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String)
    
    /**
     Convenience method for log(level: .uievent, ...)
     */
    func uiEvent(eventName: String,
                       message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String)
    /**
     Convenience method for log(level: .error, ...)
     */
    func error(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String)
}

/**
 Main Logger Proxy
 */
@objc
open class OktaLogger: NSObject, OktaLoggerProtocol {
   
    // MARK: Public

    public required init(destinations: [OktaLoggerDestinationProtocol]) {
        var destinationDict = [String:OktaLoggerDestinationProtocol]()
        for destination in destinations {
            destinationDict[destination.identifier] = destination
        }
        self.destinations = destinationDict
    }
    
    public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        
        for logger in self.destinations.values {
            // check the logging level of this destination
            let levelCheck = (logger.level.rawValue & level.rawValue) == level.rawValue
            if !levelCheck { continue }
            
            logger.log(level: level,
                       eventName: eventName,
                       message: message,
                       properties: properties ?? logger.defaultProperties,
                       file: file, line: line, funcName: funcName)
        }
    }
    
    public func setLogLevel(level: OktaLoggerLogLevel, identifiers: [String]) {
        for identifier in identifiers {
            if let destination = self.destinations[identifier] {
                destination.level = level
            }
        }
    }
    
    public func debug(eventName: String, message: String?, properties: [AnyHashable : Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .debug, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func info(eventName: String, message: String?, properties: [AnyHashable : Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .info, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func warning(eventName: String, message: String?, properties: [AnyHashable : Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .warning, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func uiEvent(eventName: String, message: String?, properties: [AnyHashable : Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .uiEvent, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func error(eventName: String, message: String?, properties: [AnyHashable : Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .error, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    /// Useful to keep public for updating all log levels
    public let destinations : [String:OktaLoggerDestinationProtocol]
}

/**
 Extension for thread-safe global logger instance get/set
 */
@objc
public extension OktaLogger {
    static var main: OktaLogger? {
        get {
            _lock.readLock()
            defer {
                _lock.unlock()
            }
            return _main
        }
        set (logger) {
            _lock.writeLock()
            defer {
                _lock.unlock()
            }
            _main = logger
        }
    }
    static private var _lock = ReadWriteLock()
    static private var _main: OktaLogger?
}
