import Foundation

/**
 Logger destination interface to be implemented by concrete loggers
 */
@objc
public protocol OktaLoggerDestination {
    
    /**
     Identifier for this logging destination, e.g. "com.okta.console" or "com.google.firebase.analytics"
     */
    var identifier: String {get}
    
    /**
     Logging level for this destination
     */
    var level: OktaLogLevel {get}
    
    /**
     Logging super-method, to be implemented by all concrete logging destinations
     
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
             column: NSNumber?,
             funcName: String?)
}
