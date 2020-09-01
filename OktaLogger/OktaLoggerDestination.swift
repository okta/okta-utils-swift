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
    var identifier: String { get }

    /**
     Logging level for this destination
     */
    var level: OktaLoggerLogLevel { get set }

    /**
     Default event properties
     */
    var defaultProperties: [AnyHashable: Any]? { get }

    /**
     Logging super-method, to be implemented by all concrete logging destinations

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
     Log NSError object.

     - Parameters
        - error: NSError object to log.
     */
    func log(error: NSError, file: String, line: NSNumber, funcName: String)
}

/**
 Abstract logger destination class, makes automates atomic level setting and simple init
 */
@objc
open class OktaLoggerDestinationBase: NSObject, OktaLoggerDestinationProtocol {
    public let identifier: String
    public let defaultProperties: [AnyHashable: Any]?

    @objc
    public init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        self.identifier = identifier
        self._level = level
        self.defaultProperties = defaultProperties
    }

    /**
     Atomic get and set using readwrite lock
     */
    public var level: OktaLoggerLogLevel {
        get {
            self.lock.readLock()
            defer { self.lock.unlock() }
            return self._level
        }
        set (value) {
            self.lock.writeLock()
            defer { self.lock.unlock() }
            self._level = value
        }
    }

    /**
     Log function must be overridden by subclasses
     */
    open func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {}

    open func logsCanBePurged() -> Bool {
        return false
    }

    open func purgeLogs() {}

    /**
     This method can be overridden by subclass.
     Default implementation will call log(level:) function with `error` level
     and pass `error.domain` and `error.code` as `eventName` parameter,
     `error.localizedDescription` as `message` and `error.userInfo` as `properties`.
     */
    open func log(error: NSError, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        let eventName = "\(error.domain), \(error.code)"
        let message = error.localizedDescription
        let properties = error.userInfo
        log(level: .error, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    /**
     Create a structured string out of the logging parameters and properties
     */
    open func stringValue(level: OktaLoggerLogLevel, eventName: String, message: String?, file: String, line: NSNumber, funcName: String) -> String {
        let filename = file.split(separator: "/").last
        let logMessageIcon = OktaLoggerLogLevel.logMessageIcon(level: level)
        return "{\(logMessageIcon) \"\(eventName)\": {\"message\": \"\(message ?? "")\", \"location\": \"\(filename ?? ""):\(funcName):\(line)\"}}"
    }

    // MARK: Private

    private var lock = ReadWriteLock()
    private var _level: OktaLoggerLogLevel
}
