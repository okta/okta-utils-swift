/*
 * Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
 * The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
 *
 * You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and limitations under the License.
 */

import Instabug
#if SWIFT_PACKAGE
import LoggerCore
#endif
///  Concrete logging destination for Instabug
open class OktaLoggerInstabugLogger: OktaLoggerDestinationBase {

    override open func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
        guard Instabug.enabled else {
            return
        }
        let logString = self.stringValue(
            level: level,
            eventName: eventName,
            message: message,
            file: file,
            line: line,
            funcName: funcName
        )
        switch level {
        case .all:
            IBGLog.logVerbose(logString)
        case .debug:
            IBGLog.logDebug(logString)
        case .info, .uiEvent:
            IBGLog.logInfo(logString)
        case .warning:
            IBGLog.logWarn(logString)
        case .error:
            IBGLog.logError(logString)
        case .off:
            return
        default:
            return
        }
    }

    override open func stringValue(level: OktaLoggerLogLevel, eventName: String, message: String?, file: String, line: NSNumber, funcName: String) -> String {
        let fileLogString = file.split(separator: "/").last ?? ""
        let messageLogString: String = {
            guard let message = message else {
                return ""
            }
            return ". \(message)"
        }()
        return "\(eventName)\(messageLogString) | \(fileLogString):\(funcName):\(line)"
    }
}
