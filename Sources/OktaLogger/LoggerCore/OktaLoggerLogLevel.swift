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
import Foundation

/**
 Dynamic logging levels for OktaLogger objects.

 Allows custom logger implementations to react to some log levels and not others.
 */
@objc
public class OktaLoggerLogLevel: NSObject, OptionSet {
    public let rawValue: Int

    public required init(rawValue: Int) {
        self.rawValue = rawValue
    }

    @objc public static let off = OktaLoggerLogLevel([])
    @objc public static let error = OktaLoggerLogLevel(rawValue: 1 << 4)
    @objc public static let uiEvent: OktaLoggerLogLevel = [OktaLoggerLogLevel(rawValue: 1 << 3), .error]
    @objc public static let warning: OktaLoggerLogLevel = [OktaLoggerLogLevel(rawValue: 1 << 2), .uiEvent]
    @objc public static let info: OktaLoggerLogLevel = [OktaLoggerLogLevel(rawValue: 1 << 1), .warning]
    @objc public static let debug: OktaLoggerLogLevel = [OktaLoggerLogLevel(rawValue: 1 << 0), .info]

    @objc public static let all: OktaLoggerLogLevel = [.debug, .info, .warning, .uiEvent, .error]
}

extension OktaLoggerLogLevel {
    /**
     Generate log message icon depends on the log level
     */

    public static func logMessageIcon(level: OktaLoggerLogLevel) -> String {
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
