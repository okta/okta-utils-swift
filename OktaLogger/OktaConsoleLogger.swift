import os

/**
 Concrete logging class for console and IDE logs.
 */
@objc
public class OktaConsoleLogger: OktaLoggerDestinationBase {
    
    override public func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?) {
        
         let logMessage = self.stringValue(eventName: eventName,
                                           message: message,
                                           properties: properties ?? self.defaultProperties,
                                           file: file, line: line, funcName: funcName)
        // translate log level into relevant console type level
        let type = self.consoleLogType(level: level)
        os_log("%s", type: type, logMessage)
    }
    
    // MARK: Private + Internal
    
    /**
     Create a structured string out of the logging parameters and properties
     */
    func stringValue(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?) -> String {
        let filename = file?.split(separator: "/").last
        return "{\"\(eventName)\": {\"message\": \"\(message ?? "")\", \"properties\": {\(properties ?? [:])}\"location\": \"\(filename ?? ""):\(funcName ?? ""):\(line ?? 0)\""
    }
    
    /**
     Translate OktaLogLevel into a console-friendly OSLogType value
     */
    func consoleLogType(level: OktaLogLevel) -> OSLogType {
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
