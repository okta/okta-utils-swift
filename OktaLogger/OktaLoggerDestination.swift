import Foundation

/**
 Logger destination protocol interface to be implemented by concrete loggers
 */
@objc
public protocol OktaLoggerDestinationProtocol {
    
    /**
     Unique for this logging destination, e.g. "com.okta.console" or "com.google.firebase.analytics"
     Only one logger per identifier is permitted
     */
    var identifier: String {get}
    
    /**
     Logging level for this destination
     */
    var level: OktaLogLevel { get set }
    
    /**
     Logging level for this destination
     */
    var defaultProperties: [AnyHashable : Any]? {get}
    
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
             funcName: String?)
}


/**
 Abstract logger destination class, makes automates atomic level setting and simple init
 */
@objc
open class OktaLoggerDestinationBase: NSObject, OktaLoggerDestinationProtocol {
    public let identifier: String
    public let defaultProperties: [AnyHashable : Any]?
    
    @objc
    public init(identifier: String, level: OktaLogLevel, defaultProperties: [AnyHashable : Any]?) {
        self.identifier = identifier
        self._level = level
        self.defaultProperties = defaultProperties
    }
    
    /**
     Atomic get and set using readwrite lock
     */
    public var level: OktaLogLevel {
        get {
            self.lock.readLock()
            defer { self.lock.unlock() }
            return self._level
        }
        set (value) {
            self.lock.writeLock()
            defer { self.lock.unlock()}
            self._level = value
        }
    }
    
    /**
     Log function must be overridden by subclasses
     */
    open func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?) {
        assert(false, "OktaLoggerDestinationBase is an abstract class")
    }
    
    // MARK: Private
    
    private var lock = ReadWriteLock()
    private var _level: OktaLogLevel
}
