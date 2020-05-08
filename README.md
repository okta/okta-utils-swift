# Design
## Goal
We want to build a logging SDK and have the ability to log events to IDE, Pendo, Firebase, etc.
## Common operation
- Should be compatible with swift and objective c
- Different logger classes for different outputs 
- Need a way to dynamically change the log level 
- Need a way to dynamically add a new logger while the app is running. 
- Some loggers might have their own unique identifier and we should have a way to pass that identifier to either User-agent or other loggers 
- Okta back end API
- Log to the local file system 
- A common identifier for the device that gets passed to all logs, this identifier will be created at the time of installation of the app.
- A configuration object that could be passed to all loggers or can be customized for one logger. hierarchy of logger configuration. 
## API example
### Pendo
```
PendoManager.shared().track("event_name", properties: ["key1":"val1", "key2":"val2"])
```
### Firebase
```
Analytics.logEvent("share_image", parameters: ["name": name as NSObject, "full_text": text as NSObject])
```
## UML diagram
![Okta Logging Framework (3)](https://user-images.githubusercontent.com/48165682/81348545-1c615100-9073-11ea-8ae7-3788f7289b26.png)
## Interface
### OktaLogLevel
```
@objc
public class OktaLogLevel: NSObject, OptionSet {
    public let rawValue: Int

    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    @objc public static let off = OktaLogLevel(rawValue: 0)
    @objc public static let debug = OktaLogLevel(rawValue: 1 << 0)
    @objc public static let info = OktaLogLevel(rawValue: 1 << 1)
    @objc public static let warning = OktaLogLevel(rawValue: 1 << 2)
    @objc public static let uiEvent = OktaLogLevel(rawValue: 1 << 3)
    @objc public static let error = OktaLogLevel(rawValue: 1 << 4)
    @objc public static let all: OktaLogLevel = [.debug, .info, .warning, .uiEvent, .error]

    static func == (lhs: OktaLogLevel, rhs: OktaLogLevel) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
```
### OktaLogOutputDestination
```
@objc
public class OktaLogOutputDestination: NSObject, OptionSet {
    public let rawValue: Int

    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    @objc public static let none = OktaLogOutputDestination(rawValue: 0)
    @objc public static let ideOnly = OktaLogOutputDestination(rawValue: 1 << 0)
    @objc public static let console = OktaLogOutputDestination(rawValue: 1 << 1)
    @objc public static let all: OktaLogOutputDestination = [.ideOnly, .console]
}
```
### OktaLoggerConfiguration
```
@objc
public class OktaLoggerConfiguration: NSObject {
    public let logLevel: OktaLogLevel
    public let outputDestination: OktaLogOutputDestination
    
    @objc public init(logLevel: OktaLogLevel = .all, outputDestination: OktaLogOutputDestination = .all) {
        self.logLevel = logLevel
        self.outputDestination = outputDestination
    }
    
    @objc public init(logger: OktaLoggingProtocol) {
        self.logLevel = logger.config.logLevel
        self.outputDestination = logger.config.outputDestination
    }
}
```
### OktaFirebaseLoggerConfiguration
```
@objc
public class OktaFirebaseLoggerConfiguration: OktaLoggerConfiguration {
    @objc override public init(logLevel: OktaLogLevel = .all, outputDestination: OktaLogOutputDestination = .all) {
        super.init(logLevel: logLevel, outputDestination: outputDestination)
    }
    
    @objc override public init(logger: OktaLoggingProtocol) {
        super.init(logger: logger)
    }
}
```
### OktaLoggingProtocol
```
@objc
public protocol OktaLoggingProtocol {
    @objc var config: OktaLoggerConfiguration {get}
    @objc var decoratedLogger: OktaLoggingProtocol? {get}
    @objc var sharedProperties: [AnyHashable: Any]? {get}
    @objc var queue: DispatchQueue {get}
    
    @objc func addDefaultProperties(properties: [AnyHashable: Any])
    @objc func removeDefaultProperties(for key: AnyHashable)
    
    @objc func debug(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?)
    @objc func info(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?)
    @objc func warning(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?)
    @objc func uiEvent(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?)
    @objc func error(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?)
}
```
### OktaLoggingOperationProtocol
```
protocol OktaLoggingOperationProtocol {
    func addLogger(logger: OktaLoggingProtocol) -> Bool
    func removeLogger(logger: OktaLoggingProtocol) -> Bool
}
```
### OktaLogger
Log to console/IDE
```
@objc
public class OktaLogger: NSObject, OktaLoggingProtocol, OktaLoggingOperationProtocol {
    public let config: OktaLoggerConfiguration
    public let queue: DispatchQueue
    private let loggerIdentfier: String?
    public let decoratedLogger: OktaLoggingProtocol?
    private(set) public var sharedProperties: [AnyHashable: Any]?
    
    @objc init(config: OktaLoggerConfiguration, queue: DispatchQueue, loggerIdentfier: String? = nil, logger: OktaLoggingProtocol? = nil, sharedProperties: [AnyHashable: Any]? = nil) {
        self.config = config
        self.queue = queue
        self.loggerIdentfier = loggerIdentfier
        self.decoratedLogger = logger
        self.sharedProperties = sharedProperties
    }
    
    @objc public func debug(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func info(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func warning(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func error(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
        queue.async {
            if self.config.logLevel.contains(.error) {
                if loggerIdentfier == nil || loggerIdentfier == self.loggerIdentfier {
                    if self.config.outputDestination.contains(.ideOnly) {
                       //Log to ide
                   }
                    if self.config.outputDestination.contains(.console) {
                       //Log to console
                   }
                }
                self.decoratedLogger?.error(loggerIdentfier: loggerIdentfier, eventName: eventName, file: file, line: line, column: column, funcName: funcName, sharedProperties: sharedProperties, properties: properties)
            }
        }
    }
    
    //Add logger to the end of the linkedlist
    @objc public func addLogger(logger: OktaLoggingProtocol, completion: (OktaLoggingProtocol?) -> Void) {
        queue.async(flags: .barrier) {
            //If loggerIdentfier, type of the logger, configuration are same, should return nil
            //If self.decoratedLogger is nil, set logger to self.decoratedLogger, return logger
            //Else pass to decoratedLogger
        }
    }
    
    //remove logger from the linkedlist
    @objc public func removeLogger(logger: OktaLoggingProtocol, completion: (Bool) -> Void) {
        queue.async(flags: .barrier) {
            //If self.decoratedLogger is nil, return false
            //If self.decoratedLogger equals to logger, self.decoratedLogger = self.decoratedLogger.decoratedLogger, return true
            //Else return false
        }
    }
    
    //Default properties would be used across all functions within the current logger object
    @objc public func addDefaultProperties(properties: [AnyHashable: Any]) {
        
    }
    
    @objc public func removeDefaultProperties(for key: AnyHashable) {
        
    }
}
```
### OktaFirebaseLogger
```
class OktaFirebaseLogger: OktaLoggingProtocol, OktaLoggingOperationProtocol {
    @objc public let config: OktaLoggerConfiguration
    public let queue: DispatchQueue
    private let loggerIdentfier: String?
    @objc public let decoratedLogger: OktaLoggingProtocol?
    @objc private(set) public var sharedProperties: [AnyHashable: Any]?

    @objc init(config: OktaLoggerFirebaseConfiguration, queue: DispatchQueue, loggerIdentfier: String? = nil, logger: OktaLoggingProtocol? = nil, sharedProperties: [AnyHashable: Any]? = nil) {
        self.config = config
        self.queue = queue
        self.loggerIdentfier = loggerIdentfier
        self.decoratedLogger = logger
        self.sharedProperties = sharedProperties
    }

    @objc public func debug(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func info(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func warning(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func error(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, sharedProperties: [AnyHashable: Any]?, properties: [AnyHashable: Any]?) {
        if config.logLevel.contains(.error) {
            if loggerIdentfier == nil || loggerIdentfier == self.loggerIdentfier {
               //Log to Firebase
            }
            decoratedLogger?.error(loggerIdentfier: loggerIdentfier, eventName: eventName, file: file, line: line, column: column, funcName: funcName, sharedProperties: sharedProperties, properties: properties)
        }
    }
    
    //Add logger to the end of the linkedlist
    @objc public func addLogger(logger: OktaLoggingProtocol, completion: (OktaLoggingProtocol?) -> Void) {
        queue.async(flags: .barrier) {
            //If loggerIdentfier, type of the logger, configuration are same, should return nil
            //If self.decoratedLogger is nil, set logger to self.decoratedLogger, return logger
            //Else pass to decoratedLogger
        }
    }
   
    //remove logger from the linkedlist
    @objc public func removeLogger(logger: OktaLoggingProtocol, completion: (Bool) -> Void) {
        queue.async(flags: .barrier) {
            //If self.decoratedLogger is nil, return false
            //If self.decoratedLogger equals to logger, self.decoratedLogger = self.decoratedLogger.decoratedLogger, return true
            //Else return false
        }
    }
    
    @objc public func addDefaultProperties(properties: [AnyHashable: Any]) {
        
    }
    
    @objc public func removeDefaultProperties(for key: AnyHashable) {
        
    }
}
```
### OktaMutableLogger
```
class OktaMutableLogger: OktaLoggingProtocol, OktaLoggingOperationProtocol {
    let loggerIdentfier: String
    let loggerList: [OktaLoggingProtocol]
    let config: OktaLoggerConfiguration
    let decoratedLogger: OktaLoggingProtocol?

    init(loggerList: [OktaLoggingProtocol]) {
        self.loggerList = loggerList
        self.config = OktaLoggerConfiguration()
        self.loggerIdentfier = ""
        self.decoratedLogger = nil
    }
    
    func debug(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    func info(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    func warning(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    func error(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable : Any]?) {
        for logger in loggerList {
            logger.error(eventName: eventName, loggerIdentfier: loggerIdentfier, file: file, line: line, column: column, funcName: funcName, properties: properties)
        }
    }
    
    func addLogger(logger: OktaLoggingProtocol) -> Bool {
        //Add logger to the list
        return true
    }
    
    func removeLogger(logger: OktaLoggingProtocol) -> Bool {
        //Remove logger from the list
        return true
    }
}
```
## Usage
```
let queue = DispatchQueue(label: "com.okta.comcurrent", attributes: .concurrent)
let config = OktaLoggerConfiguration(logLevel: .all, outputDestination: .all)
let oktaLogger = OktaLogger(config: config, queue: queue)
let firebaseConfig = OktaFirebaseLoggerConfiguration(logLevel: .all, outputDestination: .all)
let firebaseLogger1 = OktaFirebaseLogger(config: firebaseConfig, queue: queue, loggerIdentfier: nil, logger: oktaLogger, sharedProperties: nil)
let firebaseLogger2 = OktaFirebaseLogger(config: firebaseConfig, queue: queue)
firebaseLogger1.addLogger(logger: firebaseLogger2) { (logger) in}
```
firebaseLogger1 -> oktaLogger -> firebaseLogger2
