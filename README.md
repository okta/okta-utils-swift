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
![Okta Logging Framework (1)](https://user-images.githubusercontent.com/48165682/80765400-caab4a80-8af7-11ea-91c8-1ff09e05eff3.png)
## Interface
### OktaLogLevel
```
public class OktaLogLevel: OptionSet {
    public let rawValue: Int

    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let off = OktaLogLevel(rawValue: 0)
    public static let debug = OktaLogLevel(rawValue: 1 << 3)
    public static let info = OktaLogLevel(rawValue: 1 << 2)
    public static let warning = OktaLogLevel(rawValue: 1 << 1)
    public static let error = OktaLogLevel(rawValue: 1 << 0)
    public static let all: OktaLogLevel = [.debug, .info, .warning, .error]
}
```
### OktaLogOutputDestination
```
public class OktaLogOutputDestination: OptionSet {
    public let rawValue: Int

    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let none = OktaLogOutputDestination(rawValue: 0)
    public static let ideOnly = OktaLogOutputDestination(rawValue: 1 << 0)
    public static let console = OktaLogOutputDestination(rawValue: 1 << 1)
    public static let all: OktaLogOutputDestination = [.ideOnly, .console]
}

```
### OktaLoggerConfiguration
```
public class OktaLoggerConfiguration {
    public internal(set) var logLevel: OktaLogLevel
    public internal(set) var outputDestination: OktaLogOutputDestination
    
    public init(logLevel: OktaLogLevel = .all, outputDestination: OktaLogOutputDestination = .all) {
        self.logLevel = logLevel
        self.outputDestination = outputDestination
    }
    
    public init(logger: OktaLoggingProtocol) {
        self.logLevel = logger.config.logLevel
        self.outputDestination = logger.config.outputDestination
    }
}
```
### OktaLoggingSDK
Set up the logging SDK in the AppDelegate
```
class OktaLoggingSDK {
    //Default properties, will be used for all logs
    var properties: [AnyHashable: Any]?
    
    init(properties: [AnyHashable: Any]? = nil) {
    }
    
    func addProperties(properties: [AnyHashable: Any]) {
    }
    
    func removeProperty(for key: AnyHashable) {
    }
}
```
### OktaLoggingProtocol
```
public protocol OktaLoggingProtocol {
    var config: OktaLoggerConfiguration {get}
    var decoratedLogger: OktaLoggingProtocol? {get}
    
    func debug(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?)
    func info(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?)
    func warning(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?)
    func error(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?)
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
class OktaLogger: OktaLoggingProtocol, OktaLoggingOperationProtocol {
    public let config: OktaLoggerConfiguration
    public let decoratedLogger: OktaLoggingProtocol?
    let loggerIdentfier: String
    let sdk: OktaLoggingSDK
    
    init(loggerIdentfier: String, config: OktaLoggerConfiguration, logger: OktaLoggingProtocol? = nil, sdk: OktaLoggingSDK) {
        self.loggerIdentfier = loggerIdentfier
        self.config = config
        self.decoratedLogger = logger
        self.sdk = sdk
    }
    
    public func debug(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
    }
    
    public func info(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
    }
    
    public func warning(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
    }
    
    public func error(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
        if config.logLevel.contains(.error) {
            if loggerIdentfier == self.loggerIdentfier {
               if config.outputDestination.contains(.ideOnly) {
                   //Log to ide
               }
               if config.outputDestination.contains(.console) {
                   //Log to console
               }
            }
            decoratedLogger?.error(eventName: eventName, loggerIdentfier: loggerIdentfier, file: file, line: line, column: column, funcName: funcName, properties: properties)
        }
    }
    
    //Add logger to the end of the linkedlist
    @discardableResult
    func addLogger(logger: OktaLoggingProtocol) -> Bool {
        //If loggerIdentfier, type of the logger, configuration are same, should return false
        //If self.decoratedLogger is nil, set logger to self.decoratedLogger, return true
        //Else pass to decoratedLogger
        return true
    }
    
    //remove logger from the linkedlist
    @discardableResult
    func removeLogger(logger: OktaLoggingProtocol) -> Bool {
        //If self.decoratedLogger is nil, return false
        //If self.decoratedLogger equals to logger, self.decoratedLogger = self.decoratedLogger.decoratedLogger, return true
        //Else return false
        return true
    }
}
```
### OktaFirebaseLogger
```
class OktaFirebaseLogger: OktaLoggingProtocol {
    let decoratedLogger: OktaLoggingProtocol?
    let config: OktaLoggerConfiguration
    let loggerIdentfier: String
    let sdk: OktaLoggingSDK

    init(loggerIdentfier: String, config: OktaLoggerConfiguration, logger: OktaLoggingProtocol? = nil, sdk: OktaLoggingSDK) {
        self.loggerIdentfier = loggerIdentfier
        self.config = config
        self.decoratedLogger = logger
        self.sdk = sdk
    }

    func debug(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
    }
    
    func info(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
    }
    
    func warning(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
    }
    
    func error(eventName: String, loggerIdentfier: String, file: String?, line: Int?, column: Int?, funcName: String?, properties: [AnyHashable: Any]?) {
        if config.logLevel.contains(.error) {
            if loggerIdentfier == self.loggerIdentfier {
               //Log to Firebase
            }
            decoratedLogger?.error(eventName: eventName, loggerIdentfier: loggerIdentfier, file: file, line: line, column: column, funcName: funcName, properties: properties)
        }
    }
    
    //Add logger to the end of the linkedlist
    @discardableResult
    func addLogger(logger: OktaLoggingProtocol) -> Bool {
        //If loggerIdentfier, type of the logger, configuration are same, should return false
        //If self.decoratedLogger is nil, set logger to self.decoratedLogger, return true
        //Else pass to decoratedLogger
        return true
    }
    
    //remove logger from the linkedlist
    @discardableResult
    func removeLogger(logger: OktaLoggingProtocol) -> Bool {
        //If self.decoratedLogger is nil, return false
        //If self.decoratedLogger equals to logger, self.decoratedLogger = self.decoratedLogger.decoratedLogger, return true
        //Else return false
        return true
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
let sdk = OktaLoggingSDK()
let oktaLogger = OktaLogger(loggerIdentfier: "OktaLogger", config: OktaLoggerConfiguration(logLevel: .all, outputDestination: .all), sdk: sdk)
let firebaseLogger1 = OktaFirebaseLogger(loggerIdentfier: "FireBaseLogger1", config: OktaLoggerConfiguration(logLevel: .all, outputDestination: .all), logger: oktaLogger, sdk: sdk)
let firebaseLogger2 = OktaFirebaseLogger(loggerIdentfier: "FireBaseLogger2", config: OktaLoggerConfiguration(logLevel: .error, outputDestination: .all), sdk: sdk)
firebaseLogger1.addLogger(logger: firebaseLogger2)
```
firebaseLogger1 -> oktaLogger -> firebaseLogger2
