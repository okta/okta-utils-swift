import Foundation

// MARK: Logger Protocol

/**
 Abstract interface to be adopted by concrete loggers
 
 
 */
@objc
public protocol OktaLoggerProtocol {
    
    @objc func addDefaultProperties(properties: [AnyHashable: Any], identifier: String?)
    @objc func removeDefaultProperties(for key: AnyHashable, identifier: String?)
    
    @objc func debug(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func info(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func warning(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func uiEvent(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func error(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func log(logLevel: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?)
}
