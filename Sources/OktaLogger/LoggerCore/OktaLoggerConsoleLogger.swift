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
import os
import Foundation
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
        os_log("%{public}s", type: type, logMessage)
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
             return .default
        case .error, .warning:
            return .error
        default:
            return .default
        }
    }
}
