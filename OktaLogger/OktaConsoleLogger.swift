import os

@objc
public protocol OktaConsoleLoggerProtocol {
    /**
        Instantiate a concrete console logger
        
        - Parameters:
            - identifier: Logger identfier
            - level: OktaLoggingLevel
            - console: Bool to indicate whether console logging should be enabled. IDE logging is always on.
        */
       init(identifier: String, level: OktaLogLevel, console: Bool)
}

/**
 Concrete logging class for console and IDE logs.
 */
@objc
public class OktaConsoleLogger: NSObject, OktaLoggerDestination {
    public let identifier: String
    public let level: OktaLogLevel
    public let console: Bool
    
    public init(identifier: String, level: OktaLogLevel, console: Bool) {
        self.identifier = identifier
        self.level = level
        self.console = console
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    public func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, funcName: String?) {
        
         let logMessage = self.stringValue(eventName: eventName,
                                           message: message,
                                           properties: properties,
                                           file: file, line: line, funcName: funcName)
        if self.console {
            // translate log level into relevant console type level
            let type = self.consoleLogType(level: level)
            os_log("%s", type: type, logMessage)
        } else {
            // print only to ide
            let datePrefix = self.dateFormatter.string(from: Date())
            print("\(datePrefix) - \(logMessage)")
        }
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
    
    private let dateFormatter: DateFormatter
}
