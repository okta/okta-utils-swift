import Foundation

/**
 Dynamic logging levels for OktaLogger objects.
 
 Allows custom logger implementations to react to some log levels and not others.
 */
@objc
public class OktaLoggerLogLevel: NSObject, OptionSet {
    public let rawValue: Int
    required public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    @objc public static let off = OktaLoggerLogLevel([])
    @objc public static let debug = OktaLoggerLogLevel(rawValue: 1 << 0)
    @objc public static let info = OktaLoggerLogLevel(rawValue: 1 << 1)
    @objc public static let warning = OktaLoggerLogLevel(rawValue: 1 << 2)
    @objc public static let uiEvent = OktaLoggerLogLevel(rawValue: 1 << 3)
    @objc public static let error = OktaLoggerLogLevel(rawValue: 1 << 4)
    @objc public static let all: OktaLoggerLogLevel = [.debug, .info, .warning, .uiEvent, .error]
}

extension OktaLoggerLogLevel {
    
    /**
    Generate log message icon depends on the log level
    */
    
    static func logMessageIcon(level: OktaLoggerLogLevel) -> String {
        switch level {
        case .debug, .info, .uiEvent:
            return "✅"
        case .error:
            return "🛑"
        case .warning:
            return "⚠️"
        default:
            return ""
        }
    }
}
