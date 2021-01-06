// JIRA for proper fix https://oktainc.atlassian.net/browse/OKTA-350983
#if os(iOS)
import FirebaseCrashlytics

/**
 Concrete logging class for Firebase Crashlytics.
 */
@objc
open class OktaLoggerFirebaseCrashlyticsLogger: OktaLoggerDestinationBase {

    private let crashlytics: Crashlytics

    /**
     - Parameters
        - crashlytics: Fully configured and ready-to-use Crashlytics object.
                       Setup guide can be found [here](https://firebase.google.com/docs/crashlytics/get-started).
        - identifier: Unique logging destination identifier.
        - level: Logging level for this destination.
        - defaultProperties: Default event properties.
     */
    @objc
    public init(
        crashlytics: Crashlytics,
        identifier: String,
        level: OktaLoggerLogLevel
    ) {
        self.crashlytics = crashlytics
        super.init(identifier: identifier, level: level, defaultProperties: nil)
    }

    override open func log(
        level: OktaLoggerLogLevel,
        eventName: String,
        message: String?,
        properties: [AnyHashable: Any]?,
        file: String,
        line: NSNumber,
        funcName: String
    ) {
        switch level {
        case .warning, .error:
            crashlytics.record(error: NSError(
                domain: buildDomain(with: eventName),
                code: 0,
                userInfo: [
                    "level": OktaLoggerLogLevel.logMessageIcon(level: level),
                    "eventName": eventName,
                    "message": message ?? "-",
                    "file": file,
                    "line": line,
                    "function": funcName
                ])
            )
        default:
            break
        }

        crashlytics.log(self.stringValue(
            level: level,
            eventName: eventName,
            message: message,
            file: file,
            line: line,
            funcName: funcName)
        )
    }

    override open func log(error: NSError, file: String, line: NSNumber, funcName: String) {
        var extendedUserInfo = error.userInfo
        extendedUserInfo["file"] = file
        extendedUserInfo["line"] = line
        extendedUserInfo["funcName"] = funcName
        let extendedError = NSError(domain: error.domain, code: error.code, userInfo: extendedUserInfo)
        crashlytics.record(error: extendedError)
    }

    // MARK: - Private

    private func buildDomain(with eventName: String) -> String {
        let normalizedEventName = eventName.lowercased().replacingOccurrences(of: " ", with: "-")
        return "\(identifier).\(normalizedEventName)"
    }
}
#endif
