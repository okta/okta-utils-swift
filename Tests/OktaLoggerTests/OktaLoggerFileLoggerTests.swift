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
#if SWIFT_PACKAGE
@testable import FileLogger
@testable import LoggerCore
#endif

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

        // Verify that log files contains exactly 5 lines
        var receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        pollForLogCompletion(delegate: testObject, expectedMessages: ["log 1", "log 2", "log 3", "log 4", "log 5"], expectation: receiveLogsExpectation)
        wait(for: [receiveLogsExpectation], timeout: 20.0)

        // Verify that actual log files paths same as expected
        var extectedPaths = FileTestsHelper.getPaths(testObject: testObject)
        var actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, extectedPaths)
        
        testObject.purgeLogs()
        testObject.log(.debug, "After purge")
        testObject.log(.info, "After purge")
        
        // Verify that log files contains exactly 2 lines
        receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        pollForLogCompletion(delegate: testObject, expectedMessages: ["After purge", "After purge"], expectation: receiveLogsExpectation)
        wait(for: [receiveLogsExpectation], timeout: 20.0)

        // Verify that actual log files paths same as expected
        extectedPaths = FileTestsHelper.getPaths(testObject: testObject)
        actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, extectedPaths)
        testObject.purgeLogs()
    }
    
    func testLumberjackCustomNameMultipleFilesLogger() {
        let config = FileTestsHelper.defaultFileConfig
        config.maximumNumberOfLogFiles = 7
        config.rollingFrequency = 1
        config.logFileName = "TestOktaVerify.log"
        let testObject = LumberjackLoggerDelegate(config)

        // default rolling frequency
        XCTAssertEqual(testObject.fileLogger.rollingFrequency, config.rollingFrequency)
        XCTAssertNotNil(testObject.directoryPath())
        XCTAssertEqual(testObject.logsCanBePurged(), true)

        // Call log method 5 times
        for i in 1...5 {
            testObject.log(.debug, "log \(i)")
            testObject.log(.debug, "log \(i)")
            sleep(3)
        }

        // Verify that log files contains exactly 5 lines and purge logs
        var receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        pollForLogCompletion(delegate: testObject, expectedMessages: ["log 1", "log 1", "log 2", "log 2", "log 3", "log 3", "log 4", "log 4", "log 5", "log 5"], expectation: receiveLogsExpectation)
        wait(for: [receiveLogsExpectation], timeout: 10.0)

        // Verify that actual log files paths are same as expected
        var extectedPaths = Set(FileTestsHelper.getPaths(testObject: testObject, withArchived: true))
        var actualPaths = Set(testObject.getLogPaths())
        XCTAssertEqual(actualPaths, extectedPaths)

        testObject.purgeLogs()

        testObject.log(.debug, "After purge")
        testObject.log(.info, "After purge")
        receiveLogsExpectation = XCTestExpectation(description: "Should receive logs data")
        pollForLogCompletion(delegate: testObject, expectedMessages: ["After purge", "After purge"], expectation: receiveLogsExpectation)
        wait(for: [receiveLogsExpectation], timeout: 10.0)

        // Verify that actual log files paths are same as expected
        extectedPaths = Set(FileTestsHelper.getPaths(testObject: testObject, withArchived: true))
        actualPaths = Set(testObject.getLogPaths())
        XCTAssertEqual(actualPaths, extectedPaths)
        testObject.purgeLogs()
    }
    
    private func pollForLogCompletion(delegate: FileLoggerDelegate, expectedMessages: [String], expectation: XCTestExpectation) {
        let pollingInterval: TimeInterval = 3

        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + pollingInterval) {
            let getLogsExpectation = XCTestExpectation(description: "Should receive logs data")
            var logs: [Data] = []

            delegate.getLogs { result in
                logs = result
                getLogsExpectation.fulfill()
            }

            self.wait(for: [getLogsExpectation], timeout: 10.0)
            
            let messages: [String] = logs.flatMap { log -> [String] in
                guard let logString = String(data: log, encoding: .utf8) else {
                    return []
                }
                
                return logString.split(separator: "\n").map { String($0) }
            }
            
            if messages.count >= expectedMessages.count {
                for (index, message) in messages.prefix(expectedMessages.count).enumerated() {
                    if !message.hasSuffix(expectedMessages[index]) {
                        XCTFail("Expected log message: \(expectedMessages[index]), but received: \(message)")
                    }
                }

                expectation.fulfill()
                return
            }
            
            self.pollForLogCompletion(delegate: delegate, expectedMessages: expectedMessages, expectation: expectation)
        }
    }
}
