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
import XCTest
@testable import OktaLogger
#if canImport(LoggerCore)
import LoggerCore
#endif
class OktaLoggerConsoleLoggerTests: XCTestCase {

    /**
     Verify that logging to the console works as expected
     */
    func testLogToConsoleSyntax() {
        let console = OktaLoggerConsoleLogger(identifier: "hello.my.console", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [console])
        logger.debug(eventName: "Hello", message: nil)
        logger.info(eventName: "Boom", message: "crash", properties: ["what": "ever"])
        logger.error(eventName: "Boom", message: "crash", properties: ["what": "ever"])
        logger.warning(eventName: "Boom", message: "crash", properties: ["what": "ever"])
        logger.uiEvent(eventName: "Boom", message: "crash", properties: ["what": "ever"])
        logger.debug(eventName: "hello", message: "bogusness", properties: nil, file: "")
        logger.log(level: .off, eventName: "none", message: nil, properties: nil)
    }

    /**
     Verify that multithreaded logs work correctly on the console
     */
    func testMultithreadingLogToConsole() {
        let expectation = XCTestExpectation(description: "all logging complete")
        let destination = OktaLoggerConsoleLogger(identifier: "hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])

        var completed = 0
        let threads = 1000
        let serialQueue = DispatchQueue(label: "serial")
        let concQueue = DispatchQueue(label: "hello", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        for i in 0..<threads {
            concQueue.async {
                logger.debug(eventName: "\(i)", message: "Thread count: \(i)")
                serialQueue.async {
                    completed += 1
                    if completed == threads {
                        expectation.fulfill()
                    }
                }
            }
        }

        self.wait(for: [expectation], timeout: 10)
    }
}
