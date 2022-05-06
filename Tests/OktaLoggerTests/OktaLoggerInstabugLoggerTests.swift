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
import XCTest
@testable import OktaLogger
#if SWIFT_PACKAGE
@testable import InstabugLogger
#endif

class OktaLoggerInstabugLoggerTests: XCTestCase {

    var instabugLogger: OktaLoggerInstabugLogger!

    override func setUp() {
        super.setUp()
        instabugLogger = OktaLoggerInstabugLogger(
            identifier: "instabug-logger",
            level: .all,
            defaultProperties: nil
        )
    }

    func testStringValueMessageNotNil() {
        let actualLog = instabugLogger.stringValue(
            level: .info,
            eventName: "Test event",
            message: "Test message",
            file: "OktaLoggerInstabugLoggerTests.swift",
            line: 29,
            funcName: "testStringValueMessageNotNil()"
        )
        XCTAssertEqual(actualLog, "Test event. Test message | OktaLoggerInstabugLoggerTests.swift:testStringValueMessageNotNil():29")
    }

    func testStringValueMessageNil() {
        let actualLog = instabugLogger.stringValue(
            level: .info,
            eventName: "Test event",
            message: nil,
            file: "OktaLoggerInstabugLoggerTests.swift",
            line: 29,
            funcName: "testStringValueMessageNotNil()"
        )
        XCTAssertEqual(actualLog, "Test event | OktaLoggerInstabugLoggerTests.swift:testStringValueMessageNotNil():29")
    }

    func testStringValueNoFileName() {
        let actualLog = instabugLogger.stringValue(
            level: .info,
            eventName: "Test event",
            message: "Test message",
            file: "",
            line: 29,
            funcName: "testStringValueMessageNotNil()"
        )
        XCTAssertEqual(actualLog, "Test event. Test message | :testStringValueMessageNotNil():29")
    }
}
