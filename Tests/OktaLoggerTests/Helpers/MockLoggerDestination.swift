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
import OktaLogger
#if canImport(LoggerCore)
import LoggerCore
#endif
@objc
class MockLogEvent: NSObject {
    let name: String
    let message: String?
    let properties: [AnyHashable: Any]?
    let file: String?
    let line: NSNumber?
    let funcName: String?

    init(name: String,
         message: String?,
         properties: [AnyHashable: Any]?,
         file: String?,
         line: NSNumber?,
         funcName: String?) {
        self.name = name
        self.message = message
        self.properties = properties
        self.file = file
        self.line = line
        self.funcName = funcName
    }
}

@objc
class MockLoggerDestination: OktaLoggerDestinationBase {
    var events = [MockLogEvent]()
    var eventMessages = [String]()
    let serialQueue = DispatchQueue(label: UUID().uuidString)

    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
        let event = MockLogEvent(name: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
        serialQueue.sync {
            self.events.append(event)
            self.eventMessages.append(stringValue(level: level, eventName: eventName, message: message, file: file, line: line, funcName: funcName))
        }
    }

    override func log(error: NSError, file: String, line: NSNumber, funcName: String) {
        let event = MockLogEvent(name: "Error \(error.domain) \(error.code)", message: nil, properties: error.userInfo, file: file, line: line, funcName: funcName)
        serialQueue.sync {
            self.events.append(event)
        }
    }
}
