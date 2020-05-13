import os

@objc
public class OktaConsoleLogger: NSObject, OktaLoggerDestination {
    public let identifier: String
    var level: OktaLogLevel
    
    init(identifier: String, level: OktaLogLevel) {
        self.identifier = identifier
        self.level = level
    }
    
    public func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        if level.contains(self.level) {
            os_log("Hello World: %s", eventName)
        }
    }
}
