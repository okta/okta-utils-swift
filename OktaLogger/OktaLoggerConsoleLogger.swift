import os

/**
 Concrete logging class for console and IDE logs.
 */
@objc
public class OktaLoggerConsoleLogger: OktaLoggerDestinationBase {

    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {

         let logMessage = stringValue(level: level,
                                           eventName: eventName,
                                           message: message,
                                           file: file, line: line, funcName: funcName)
        // translate log level into relevant console type level
        let type = self.consoleLogType(level: level)
        os_log("%s", type: type, logMessage)
    }

    // MARK: Private + Internal

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
