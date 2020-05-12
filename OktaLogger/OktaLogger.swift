import Foundation

/**
 Public interface for main OktaLogger instances
 */
@objc
protocol OktaLoggerInterface: OktaLogging {
    
    /**
     Convenience method for log(level: .debug)
     */
    @objc func debug(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .info)
     */
    @objc func info(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .warning)
     */
    @objc func warning(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Convenience method for log(level: .uievent)
     */
    @objc func uiEvent(eventName: String,
                       message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    /**
     Convenience method for log(level: .error)
     */
    @objc func error(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?)
    
    /**
     Set default property dict for a given logging destination
     
     - Parameters:
     - properties: Key-value pairs of properties to be applied to logs
     - identifier: Logger identifier, nil will apply to all loggers
     */
    @objc func addDefaultProperties(properties: [AnyHashable : Any], identifier: String?)
    
    /**
     Remove default properties for a given logging identifier
     
     - Parameters:
     - identifier: Logger identifier, nil applies to all loggers
     */
    @objc func removeDefaultProperties(identifier: String?)
    
    /**
     Add a logging destination to the Logger
     
     - Parameters:
        - dest: Concrete logger destination to be added
     */
    @objc func addDestination(_ dest: OktaLoggerDestination)
    
    /**
    Remove a logging destination
    
    - Parameters:
       - dest: Concrete logger destination to be removed
    */
    @objc func removeDestination(_ dest: OktaLoggerDestination)
}

/**
 Main Logger Proxy
 */
class OktaLogger: OktaLoggerInterface {
    
    private var loggerList = [String:OktaLoggerDestination]()
    private let serialQueue = DispatchQueue(label: "okta.logger.serial")
    @objc public init(loggers: [OktaLoggerDestination]) {
        for logger in loggers {
            loggerList[logger.identifier] = logger
        }
    }
    
    // MARK: Public
    
    func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, identifier: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
            // log to one ore more loggers
      }
    
    func debug(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        log(level: .debug, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    func info(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        log(level: .info, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    func warning(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        log(level: .warning, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    func uiEvent(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        log(level: .uiEvent, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    func error(eventName: String, message: String?, properties: [AnyHashable : Any], file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        log(level: .error, eventName: eventName, message: message, properties: properties, identifier: nil, file: file, line: line, column: column, funcName: funcName)
    }
    
    func removeDestination(_ dest: OktaLoggerDestination) {}
    
    func addDestination(_ dest: OktaLoggerDestination) {}
    
    func addDefaultProperties(properties: [AnyHashable : Any], identifier: String?) {}
       
    func removeDefaultProperties(identifier: String?) {}
}
