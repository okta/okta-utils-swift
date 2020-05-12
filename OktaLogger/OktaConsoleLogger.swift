import os

class OktaConsoleLogger: OktaLoggerDestination {
    let identifier: String
    var level: OktaLogLevel
    
    init(identifier: String, level: OktaLogLevel) {
        self.identifier = identifier
        self.level = level
    }
    
    func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, identifier: String?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        if level.rawValue >= self.level.rawValue {
            // generate a log string
        }
    }
}
