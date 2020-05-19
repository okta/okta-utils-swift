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
```swift
PendoManager.shared().track("event_name", properties: ["key1":"val1", "key2":"val2"])
```
### Firebase
```swift
Analytics.logEvent("share_image", parameters: ["name": name as NSObject, "full_text": text as NSObject])
```
## UML diagram
![Okta Logging Framework (6)](https://user-images.githubusercontent.com/48165682/81611685-53e03e00-9390-11ea-8996-1da9ad2eaac8.png)
## Interface
### OktaLogLevel
```swift
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
```swift
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
```swift
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
```swift
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
```swift
@objc
public protocol OktaLoggingProtocol {
    @objc var config: OktaLoggerConfiguration {get}
    
    @objc func addDefaultProperties(properties: [AnyHashable: Any], identifier: String?)
    @objc func removeDefaultProperties(for key: AnyHashable, identifier: String?)
    
    @objc func debug(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func info(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func warning(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func uiEvent(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func error(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable: Any]?)
    @objc func log(logLevel: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?)
}
```
### OktaMutableLoggerProtocol
```swift
@objc
public protocol OktaLoggingOperationProtocol {
    @objc func addLogger(logger: OktaLoggingProtocol)
    @objc func removeLogger(logger: OktaLoggingProtocol)
}
```
### OktaLogger
Log to console/IDE
```swift
@objc
public class OktaLogger: NSObject, OktaLoggingProtocol {
    public let config: OktaLoggerConfiguration
    private let loggerIdentifier: String?
    private var defaultProperties: [AnyHashable: Any]?
    
    @objc init(config: OktaLoggerConfiguration, loggerIdentifier: String? = nil) {
        self.config = config
        self.loggerIdentifier = loggerIdentifier
    }
    
    @objc public func debug(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func info(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func warning(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func error(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
        if (loggerIdentifier == nil || loggerIdentifier == self.loggerIdentifier) && self.config.logLevel.contains(.error) {
            if self.config.outputDestination.contains(.ideOnly) {
               //Log to ide
            }
            if self.config.outputDestination.contains(.console) {
               //Log to console
            }
        }
    }
    
    @objc public func log(logLevel: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func addDefaultProperties(properties: [AnyHashable : Any], identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentifier {
            //add properties to self.defaultProperties
        }
    }
    
    @objc public func removeDefaultProperties(for key: AnyHashable, identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentifier {
            //remove properties to self.defaultProperties
        }
    }
}
```
### OktaFirebaseLogger
```swift
class OktaFirebaseLogger: OktaLoggingProtocol {
    @objc public let config: OktaLoggerConfiguration
    private let loggerIdentifier: String?
    private var defaultProperties: [AnyHashable: Any]?

    @objc init(config: OktaFirebaseLoggerConfiguration, loggerIdentifier: String? = nil) {
        self.config = config
        self.loggerIdentifier = loggerIdentifier
    }
    
    @objc public func debug(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func info(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func warning(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func error(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
        if (loggerIdentifier == nil || loggerIdentifier == self.loggerIdentifier) && self.config.logLevel.contains(.error) {
            //Log to Firebase
        }
    }
    
    @objc public func log(logLevel: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?) {
    }
    
    @objc public func addDefaultProperties(properties: [AnyHashable : Any], identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentifier {
            //add properties to self.defaultProperties
        }
    }
    
    @objc public func removeDefaultProperties(for key: AnyHashable, identifier: String?) {
        if identifier == nil || identifier == self.loggerIdentifier {
            //remove properties to self.defaultProperties
        }
    }
}
```
### OktaMutableLogger
```swift
class OktaMutableLogger: OktaLoggingProtocol, OktaMutableLoggerProtocol {
    let config: OktaLoggerConfiguration
    let loggerList: [OktaLoggingProtocol]
    private let serialQueue = DispatchQueue(label: "okta.logger.serial")

    @objc public init(loggerList: [OktaLoggingProtocol]) {
        self.loggerList = loggerList
        self.config = OktaLoggerConfiguration()
    }
  
    @objc public func debug(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func info(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func warning(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func uiEvent(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
    }
    
    @objc public func error(loggerIdentifier: String?, eventName: String, message: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?, properties: [AnyHashable : Any]?) {
        serialQueue.async {
            for logger in self.loggerList {
                logger.error(loggerIdentifier: loggerIdentifier, eventName: eventName, message: message, file: file, line: line, column: column, funcName: funcName, properties: properties)
            }
        }
    }
    
    @objc public func log(logLevel: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?) {
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
            //If loggerIdentifier, type of the logger, configuration are same, should not add to the loggerList
            //Else add to the loggerList
        }
    }
    
    @objc public func removeLogger(logger: OktaLoggingProtocol) {
        serialQueue.async {
            //If loggerIdentifier, type of the logger, configuration are same, remove logger from the loggerList
            //Else keep the logger
        }
    }
}
```
## Usage
```swift
    let config = OktaLoggerConfiguration(logLevel: .all, outputDestination: .all)
    let oktaLogger = OktaLogger(config: config)
    let firebaseConfig = OktaFirebaseLoggerConfiguration(logLevel: .all, outputDestination: .all)
    let firebaseLogger1 = OktaFirebaseLogger(config: firebaseConfig, loggerIdentifier: "com.okta.firebaselogger")
    let firebaseLogger2 = OktaFirebaseLogger(config: firebaseConfig)
    let loggerManager = OktaMutableLogger(loggerList: [oktaLogger, firebaseLogger1, firebaseLogger2])
    loggerManager.error(loggerIdentifier:eventName:message:file:line:column:funcName:properties:)
```
## Feature enhancement
- Convert NSError to our log message
