import os

/**
 Concrete logging class for console and IDE logs.
 */
@objc
public class OktaConsoleLogger: NSObject, OktaLoggerDestination {
    public let identifier: String
    public let level: OktaLogLevel
    public let console: Bool
    
    /**
     Instantiate a concrete console logger
     
     - Parameters:
         - identifier: Logger identfier
         - level: OktaLoggingLevel
         - console: Bool to indicate whether console logging should be enabled. IDE logging is always on.
     */
    init(identifier: String, level: OktaLogLevel, console: Bool = true) {
        self.identifier = identifier
        self.level = level
        self.console = console
    }
    
    public func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        
         let logMessage = self.stringValue(eventName: eventName,
                                           message: message,
                                           properties: properties,
                                           file: file, line: line, column: column, funcName: funcName)
        if self.console {
            // translate log level into relevant console type level
            let type = self.type(level: level)
            os_log("%s", type: type, logMessage)
        } else {
            // print only to ide
            print(logMessage)
        }
    }
    
    /**
     Create a structured string out of the log d
     */
    private func stringValue(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) -> String {
        return "{\"\(eventName)\": {\"message\": \"\(message ?? "")\", \"properties\": {\(properties ?? [:])}\"location\": \"\(file ?? ""):\(funcName ?? ""):\(line ?? 0)\""
    }
    
    /**
     Translate OktaLogLevel into a console-friendly OSLogType value
     */
    private func type(level: OktaLogLevel) -> OSLogType {
        switch level {
        case .debug:
            return .debug
        case .info, .warning, .uiEvent:
             return .info
        case .error:
            return .error
        default:
            return .default
        }
    }
}
