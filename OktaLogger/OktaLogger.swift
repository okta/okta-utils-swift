import Foundation

// MARK: Logger Protocol

/**
 Abstract interface to be adopted by concrete loggers
 */
@objc
public protocol OktaLoggerProtocol {
    /**
     Logging super-method, called by other methods
     
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
