import os

/**
 Concrete logging class for console and IDE logs.
 */
@objc
public class OktaLoggerConsoleLogger: OktaLoggerDestinationBase {
    
    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String) {
        
         let logMessage = self.stringValue(level: level,
                                           eventName: eventName,
                                           message: message,
                                           file: file, line: line, funcName: funcName)
        // translate log level into relevant console type level
        let type = self.consoleLogType(level: level)
        os_log("%s", type: type, logMessage)
    }
    
    // MARK: Private + Internal
    
    /**
     Create a structured string out of the logging parameters and properties
     */
    func stringValue(level: OktaLoggerLogLevel, eventName: String, message: String?, file: String, line: NSNumber, funcName: String) -> String {
        let filename = file.split(separator: "/").last
        let logMessageIcon = OktaLoggerLogLevel.logMessageIcon(level: level)
        return "{\(logMessageIcon) \"\(eventName)\": {\"message\": \"\(message ?? "")\", \"location\": \"\(filename ?? ""):\(funcName):\(line)\"}}"
    }
    
    /**
     Translate OktaLoggerLogLevel into a console-friendly OSLogType value
     */
    func consoleLogType(level: OktaLoggerLogLevel) -> OSLogType {
        switch level {
        case .debug:
            return .debug
        case .info, .uiEvent:
             return .info
        case .error, .warning:
            return .error
        default:
            return .default
        }
    }
}
