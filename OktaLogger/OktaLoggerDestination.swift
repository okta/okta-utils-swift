import Foundation

/**
 Logger destination interface to be implemented by concrete loggers
 */
@objc
public protocol OktaLogging {
    /**
     Logging super-method, to be implemented by concrete logging destinations
     
     - Parameters:
       - level: OktaLogLevel for this event
       - eventName: name for this event
       - message: message for this event (optional)
       - properties: key-value properties for this event (optional)
       - identifier: logger identifier for this event
          */
    @objc func log(level: OktaLogLevel,
                   eventName: String,
                   message: String?,
                   properties: [AnyHashable: Any]?,
                   identifier: String?,
                   file: String?,
                   line: NSNumber?,
                   column: NSNumber?,
                   funcName: String?)
    
}

/**
 Logger destination interface to be implemented by concrete loggers
 */
@objc
public protocol OktaLoggerDestination: OktaLogging {
    
    /**
     Identifier for this logging destination, e.g. "com.okta.console" or "com.google.firebase.analytics"
     */
    var identifier: String {get}
}
