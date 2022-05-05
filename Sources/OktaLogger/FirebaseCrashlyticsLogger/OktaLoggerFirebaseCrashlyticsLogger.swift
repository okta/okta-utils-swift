/*
 * Copyright (c) 2020-Present, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import FirebaseCrashlytics
#if canImport(LoggerCore)
import LoggerCore
#endif
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
        super.init(identifier: identifier, level: level, defaultProperties: [:])
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
            let userInfo = Self.createUserInfoDict(level: level,
                                                   eventName: eventName,
                                                   message: message,
                                                   properties: properties,
                                                   defaultProperties: defaultProperties,
                                                   file: file,
                                                   line: line,
                                                   funcName: funcName)

            crashlytics.record(error: NSError(
                domain: buildDomain(with: eventName),
                code: 0,
                userInfo: userInfo)
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

    class func createUserInfoDict(level: OktaLoggerLogLevel,
                                  eventName: String,
                                  message: String?,
                                  properties: [AnyHashable: Any]?,
                                  defaultProperties: [AnyHashable: Any]?,
                                  file: String,
                                  line: NSNumber,
                                  funcName: String) -> [String: Any] {
        var userInfo: [String: Any] = [
            "level": OktaLoggerLogLevel.logMessageIcon(level: level),
            "eventName": eventName,
            "message": message ?? "-",
            "file": file,
            "line": line,
            "function": funcName
        ]

        // merge destination-level properties into userInfo (high priority)
        if let defaultProperties = defaultProperties as? [String: Any],
           !defaultProperties.isEmpty {
            userInfo.merge(defaultProperties) { (_, last) in last }
        }

        // merge log-level properties into userInfo (highest priority)
        if let properties = properties as? [String: Any],
           !properties.isEmpty {
            userInfo.merge(properties) { (_, last) in last }
        }

        return userInfo
    }
}
