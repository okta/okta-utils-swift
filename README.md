# Design
## Goal
We want to build a logging SDK and have the ability to log event to IDE, Pendo, Firebase, etc.
## Common operation
- Should be compatible with swift and objective c
- Different logger classes for different outputs 
- Okta back end API
- Log to the local file system 
- A common identifier for the device that gets passed to all logs, this identifier will be created at the time of installation of the app.
- A configuration object that could be passed to all loggers or can be customized for one logger. hierarchy of logger configuration. 
- Some loggers might have their own unique identifier and we should have a way to pass that identifier to either User-agent or other loggers 
- Need a way to dynamically change the log level 
- Need a way to dynamically add a new logger while the app is running. 
## API example
### Pendo
```
PendoManager.shared().track("event_name", properties: ["key1":"val1", "key2":"val2"])
```
### Firebase
```
Analytics.logEvent("share_image", parameters: ["name": name as NSObject, "full_text": text as NSObject])
```
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
