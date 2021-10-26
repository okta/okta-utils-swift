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

class OktaLoggerFileLoggerTests: XCTestCase {

    override class func tearDown() {
        FileTestsHelper.cleanUpLogs()
    }

    func testOktaFileLogger() {
        let testObject: OktaLoggerFileLogger = OktaLoggerFileLogger(
            logConfig: FileTestsHelper.defaultFileConfig,
            identifier: "hello.world",
            level: .all,
            defaultProperties: nil
        )
        let logger = OktaLogger(destinations: [testObject])
        XCTAssertEqual(testObject.logsCanBePurged(), true)

        // Call log method 5 times
        for i in 1...5 {
            logger.debug(eventName: "BEFORE_PURGE", message: "\(i):log message")
        }

        // Verify that log files contains exactly 5 lines and purge logs
        var receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        var logs: [Data] = []
        testObject.getLogs { result in
            logs = result
            receiveLogsExpectation.fulfill()
        }
        wait(for: [receiveLogsExpectation], timeout: 10.0)
        XCTAssertEqual(FileTestsHelper.countLines(logs[0]), 5)
        testObject.purgeLogs()

        // Call log method 2 times
        logger.debug(eventName: "AFTER_PURGE", message: "Debug log")
        logger.info(eventName: "AFTER_PURGE", message: "Debug log")

        // Verify that log files contains exactly 2 lines
        receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        logs = []
        testObject.getLogs { result in
            logs = result
            receiveLogsExpectation.fulfill()
        }
        wait(for: [receiveLogsExpectation], timeout: 10.0)
        XCTAssertEqual(FileTestsHelper.countLines(logs[0]), 2)
        testObject.purgeLogs()
    }

    func testLumberjackFileLogger() {
        let config = FileTestsHelper.defaultFileConfig
        let testObject = LumberjackLoggerDelegate(config)

        // default rolling frequency
        XCTAssertEqual(testObject.fileLogger.rollingFrequency, config.rollingFrequency)
        XCTAssertNotNil(testObject.directoryPath())
        XCTAssertEqual(testObject.logsCanBePurged(), true)

        // Call log method 5 times
        for i in 1...5 {
            testObject.log(.debug, "log \(i)")
        }

        // Verify that log files contains exactly 5 lines and purge logs
        var receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        var logs: [Data] = []
        testObject.getLogs { result in
            logs = result
            receiveLogsExpectation.fulfill()
        }
        wait(for: [receiveLogsExpectation], timeout: 10.0)
        XCTAssertEqual(FileTestsHelper.countLines(logs[0]), 5)

        // Verify that actual log files paths same as expected
        var extectedPaths = FileTestsHelper.getPaths(testObject: testObject)
        var actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, extectedPaths)
        testObject.purgeLogs()

        testObject.log(.debug, "After purge")
        testObject.log(.info, "After purge")
        receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        testObject.getLogs { result in
            logs = result
            receiveLogsExpectation.fulfill()
        }
        wait(for: [receiveLogsExpectation], timeout: 10.0)
        XCTAssertEqual(FileTestsHelper.countLines(logs[0]), 2)

        // Verify that actual log files paths same as expected
        extectedPaths = FileTestsHelper.getPaths(testObject: testObject)
        actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, extectedPaths)
        testObject.purgeLogs()
    }
}
