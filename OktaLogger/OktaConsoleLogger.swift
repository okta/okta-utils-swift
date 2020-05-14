import os

/**
 Console logger options for ide / console / both
 */
@objc
public class OktaConsoleLoggerOptions: NSObject, OptionSet {
    public let rawValue: Int
    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    @objc public static let off = OktaConsoleLoggerOptions(rawValue: 0)
    @objc public static let console = OktaConsoleLoggerOptions(rawValue: 1 << 0)
    @objc public static let ide = OktaConsoleLoggerOptions(rawValue: 1 << 1)
    @objc public static let all: OktaConsoleLoggerOptions = [.console, .ide]
}

@objc
public class OktaConsoleLogger: NSObject, OktaLoggerDestination {
    public let identifier: String
    public let options: OktaConsoleLoggerOptions
    var level: OktaLogLevel
    
    init(identifier: String, level: OktaLogLevel, options: OktaConsoleLoggerOptions) {
        self.identifier = identifier
        self.level = level
        self.options = options
    }
    
    public func log(level: OktaLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) {
        
         let logMessage = self.stringValue(eventName: eventName,
                                           message: message,
                                           properties: properties,
                                           file: file, line: line, column: column, funcName: funcName)
        if self.options.contains(.console) {
            os_log("%s", logMessage)
        }
        if self.options.contains(.ide) {
            print(logMessage)
        }
    }
    
    private func stringValue(eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String?, line: NSNumber?, column: NSNumber?, funcName: String?) -> String {
        return "{\"\(eventName)\": {\"message\": \"\(message ?? "")\", \"file\": \"\(file ?? ""):\(funcName ?? ""):\(line ?? 0)\""
    }
}
