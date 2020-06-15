import Foundation

/**
Internal utility class
*/
class OktaLoggerUtility {
    
    /**
    Generate log message icon depends on the log level
    */
    static func generateLogMessageIcon(level: OktaLoggerLogLevel) -> String {
        switch level {
        case .all, .debug, .info, .uiEvent, .off:
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
