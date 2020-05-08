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
![Okta Logging Framework (5)](https://user-images.githubusercontent.com/48165682/81440618-36f40280-9125-11ea-906d-72cd6c6446d1.png)
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
    
    @objc func addDefaultProperties(properties: [AnyHashable: Any], identifier: String?)
    @objc func removeDefaultProperties(for key: AnyHashable, identifier: String?)
    
    @objc func debug(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func info(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func warning(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func uiEvent(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func error(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
}
```
### OktaLoggingOperationProtocol
```
@objc
public protocol OktaLoggingOperationProtocol {
    @objc func addLogger(logger: OktaLoggingProtocol)
    @objc func removeLogger(logger: OktaLoggingProtocol)
}
```
### OktaLogger
Log to console/IDE
```
@objc
public class OktaLogger: NSObject, OktaLoggingProtocol {
    public let config: OktaLoggerConfiguration
    private let loggerIdentfier: String?
    private var defaultProperties: [AnyHashable: Any]?
    
    @objc init(config: OktaLoggerConfiguration, loggerIdentfier: String? = nil) {
        self.config = config
        self.loggerIdentfier = loggerIdentfier
    }
    
    @objc public func debug(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func info(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func warning(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func error(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
        if (loggerIdentfier == nil || loggerIdentfier == self.loggerIdentfier) && self.config.logLevel.contains(.error) {
            if self.config.outputDestination.contains(.ideOnly) {
               //Log to ide
            }
            if self.config.outputDestination.contains(.console) {
               //Log to console
            }
        }
    }
    
    @objc public func addDefaultProperties(properties: [AnyHashable : Any], identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentfier {
            //add properties to self.defaultProperties
        }
    }
    
    @objc public func removeDefaultProperties(for key: AnyHashable, identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentfier {
            //remove properties to self.defaultProperties
        }
    }
}
```
### OktaFirebaseLogger
```
class OktaFirebaseLogger: OktaLoggingProtocol {
    @objc public let config: OktaLoggerConfiguration
    private let loggerIdentfier: String?

    @objc init(config: OktaFirebaseLoggerConfiguration, loggerIdentfier: String? = nil) {
        self.config = config
        self.loggerIdentfier = loggerIdentfier
    }
    
    @objc public func debug(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func info(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func warning(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func error(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
        if (loggerIdentfier == nil || loggerIdentfier == self.loggerIdentfier) && self.config.logLevel.contains(.error) {
            //Log to Firebase
        }
    }
    
    @objc public func addDefaultProperties(properties: [AnyHashable : Any], identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentfier {
            //add properties to self.defaultProperties
        }
    }
    
    @objc public func removeDefaultProperties(for key: AnyHashable, identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentfier {
            //remove properties to self.defaultProperties
        }
    }
}
```
### OktaMutableLogger
```
class OktaMutableLogger: OktaLoggingProtocol, OktaLoggingOperationProtocol {
    let config: OktaLoggerConfiguration
    let loggerList: [OktaLoggingProtocol]
    private let serialQueue = DispatchQueue(label: "okta.logger.serial")

    @objc public init(loggerList: [OktaLoggingProtocol]) {
        self.loggerList = loggerList
        self.config = OktaLoggerConfiguration()
    }
  
    @objc public func debug(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func info(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func warning(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func error(loggerIdentfier: String?, eventName: String, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
        serialQueue.async {
            for logger in self.loggerList {
                logger.error(loggerIdentfier: loggerIdentfier, eventName: eventName, file: file, line: line, column: column, funcName: funcName, properties: properties)
            }
        }
    }
    
    @objc public func addDefaultProperties(properties: [AnyHashable: Any], identifier: String?) {
        serialQueue.async {
            for logger in self.loggerList {
                logger.addDefaultProperties(properties: properties, identifier: identifier)
            }
        }
    }
    
    @objc public func removeDefaultProperties(for key: AnyHashable, identifier: String?) {
        serialQueue.async {
            for logger in self.loggerList {
                logger.removeDefaultProperties(for: key, identifier: identifier)
            }
        }
    }
    
    @objc public func addLogger(logger: OktaLoggingProtocol) {
        serialQueue.async {
            //If loggerIdentfier, type of the logger, configuration are same, should not add to the loggerList
            //Else add to the loggerList
        }
    }
    
    @objc public func removeLogger(logger: OktaLoggingProtocol) {
        serialQueue.async {
            //If loggerIdentfier, type of the logger, configuration are same, remove logger from the loggerList
            //Else keep the logger
        }
    }
}
```
## Usage
```
let config = OktaLoggerConfiguration(logLevel: .all, outputDestination: .all)
let oktaLogger = OktaLogger(config: config)
let firebaseConfig = OktaFirebaseLoggerConfiguration(logLevel: .all, outputDestination: .all)
let firebaseLogger1 = OktaFirebaseLogger(config: firebaseConfig, loggerIdentfier: "com.okta.firebaselogger")
let firebaseLogger2 = OktaFirebaseLogger(config: firebaseConfig)
let loggerManager = OktaMutableLogger(loggerList: [oktaLogger, firebaseLogger1, firebaseLogger2])
loggerManager.error(loggerIdentfier:eventName:file:line:column:funcName:properties:)
```
