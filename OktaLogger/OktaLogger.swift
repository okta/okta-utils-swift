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
    init(destinations: [OktaLoggerDestination])
    
    /**
    Logging super-method for all parameters
    
    - Parameters:
      - level: OktaLogLevel for this event
      - eventName: name for this event
      - message: message for this event (optional)
      - properties: key-value properties for this event (optional)
         */
    func log(level: OktaLogLevel,
             eventName: String,
             message: String?,
             properties: [AnyHashable: Any]?,
             file: String?,
             line: NSNumber?,
             funcName: String?)
    
    /**
     Convenience method for log(level: .debug, ...)
     */
    func debug(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .info, ...)
     */
    func info(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .warning, ...)
     */
    func warning(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .uievent, ...)
     */
    func uiEvent(eventName: String,
                       message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?)
    /**
     Convenience method for log(level: .error, ...)
     */
    func error(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?)
}

/**
 Main Logger Proxy
 */
@objc
open class OktaLogger: NSObject, OktaLoggerProtocol {
   
    // MARK: Public
    
    public required init(destinations: [OktaLoggerDestination]) {
        var destinationDict = [String:OktaLoggerDestination]()
        for destination in destinations {
            destinationDict[destination.identifier] = destination
        }
        self.destinations = destinationDict
    }
    
    deinit {
        // wait for any outstanding read locks to complete before destroying
        pthread_rwlock_wrlock(&self.lock)
        pthread_rwlock_unlock(&self.lock)
        pthread_rwlock_destroy(&self.lock)
    }
    
    public func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?) {
        pthread_rwlock_rdlock(&self.lock)
        defer { pthread_rwlock_unlock(&self.lock) }

        for logger in self.destinations.values {
            // check the logging level of this destination
            let levelCheck = (logger.level.rawValue & level.rawValue) == level.rawValue
            if !levelCheck {return}
            
            logger.log(level: level,
                       eventName: eventName,
                       message: message,
                       properties: properties,
                       file: file, line: line, funcName: funcName)
        }
    }
    
    public func debug(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, funcName: String? = #function) {
        log(level: .debug, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func info(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, funcName: String? = #function) {
        log(level: .info, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func warning(eventName: String, message: String?, properties: [AnyHashable : Any]? = nil, file: String? = #file, line: NSNumber? = #line, funcName: String? = #function) {
        log(level: .warning, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func uiEvent(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, funcName: String? = #function) {
        log(level: .uiEvent, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    public func error(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String? = #file, line: NSNumber? = #line, funcName: String? = #function) {
        log(level: .error, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
    
    // MARK: Private / Internal
    
    let destinations : [String:OktaLoggerDestination]
    private var lock: pthread_rwlock_t = {
        var lock = pthread_rwlock_t()
        pthread_rwlock_init(&lock, nil)
        return lock
    }()
}
