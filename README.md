# Design
## Goal
We want to build a logging SDK and have the ability to log events to IDE, Pendo, Firebase, etc.
## Common operation
- Should be compatible with swift and objective-c
- Support single input to multiple output logger classes (e.g. console, firebase, filesystem) 
- Make it possible to change the log level of any output destination during runtime
- Future needs: Okta backend logging API
- A common identifier for the device that gets passed to all logs, this identifier will be created at the time of installation of the app.
- Default properties for logging destination in order always log items such ase device identifier.

## API example
Existing logging outputs take events and key-value pairs. These are supported by OktaLogger and are passed to the target logging destinations.
### Pendo
```swift
PendoManager.shared().track("event_name", properties: ["key1":"val1", "key2":"val2"])
```
### Firebase
```swift
Analytics.logEvent("share_image", parameters: ["name": name as NSObject, "full_text": text as NSObject])
```
### OktaLogger
```swift
logger.logUiEvent("share_image", message: nil, parameters: ["name": name as NSObject, "full_text": text as NSObject])
```

## Usage
### Swift
```swift
    // initialization
    let console = OktaConsoleDestination(identifier: "com.okta.console.logger", level: .all, defaultProperties: nil)
    let firebase = OktaFirebaseDestination(dentifier: "com.okta.firebaselogger", level: .error, defaultProperties: nil)
    OktaLogger.main = OktaLogger(destinations: [console, firebase])
    
    // Logging
    OktaLogger.main.error(eventName: "TOTP Failure", message:"Could not retrieve key for RSA Key: ab43csd")
    
    // Changing log levels
    OktaLogger.main.setLogLevel(level: [.warn, .error], [console.identifier, firebase.identifier])
```
### Objective-C
```objc
    OktaConsoleDestination *console = [[OktaConsoleDestination alloc]
                                        initWithIdenitfier:@"com.okta.console.logger" 
                                                     level:OktaLevel.all 
                                        defaultProperties:nil];
    OktaLogger.main = [[OktaLogger alloc] initWithDestinations:@[console]];

    // Objective-c macro defined for convenience
    okl_error(@"TOTP Failure", "Could not retrieve key for RSA Key: %@", key);
```
