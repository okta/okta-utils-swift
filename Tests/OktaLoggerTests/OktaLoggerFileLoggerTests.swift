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
        var expectedMessages = ["1:log message", "2:log message", "3:log message", "4:log message", "5:log message"]
        var expectation = XCTestExpectation(description: "Should receive logs: \(expectedMessages.joined(separator: ", "))")
        pollForLogCompletion(delegate: testObject, expectedMessages: expectedMessages, expectation: expectation)
        wait(for: [expectation], timeout: Double(expectedMessages.count) * 6.0)

        // Call log method 2 times
        var logPaths = testObject.getLogPaths()
        testObject.purgeLogs()
        expectation = XCTestExpectation(description: "Logs should purge before second write")
        pollForPurgeCompletion(urls: logPaths, expectation: expectation)
        wait(for: [expectation], timeout: 20)
        
        logger.debug(eventName: "AFTER_PURGE", message: "Debug log")
        logger.info(eventName: "AFTER_PURGE", message: "Debug log")

        // Verify that log files contains exactly 2 lines
        expectedMessages = ["Debug log", "Debug log"]
        expectation = XCTestExpectation(description: "Should receive logs: \(expectedMessages.joined(separator: ", "))")
        pollForLogCompletion(delegate: testObject, expectedMessages: expectedMessages, expectation: expectation)
        wait(for: [expectation], timeout: Double(expectedMessages.count) * 6.0)
        
        logPaths = testObject.getLogPaths()
        testObject.purgeLogs()
        expectation = XCTestExpectation(description: "Logs should purge on completion")
        pollForPurgeCompletion(urls: logPaths, expectation: expectation)
        wait(for: [expectation], timeout: 20)
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
        var expectedMessages = ["log 1", "log 2", "log 3", "log 4", "log 5"]
        var expectation = XCTestExpectation(description: "Should receive logs: \(expectedMessages.joined(separator: ", "))")
        pollForLogCompletion(delegate: testObject, expectedMessages: expectedMessages, expectation: expectation)
        wait(for: [expectation], timeout: Double(expectedMessages.count) * 6.0)

        // Verify that actual log files paths same as expected
        var expectedPaths = FileTestsHelper.getPaths(testObject: testObject)
        var actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, expectedPaths)

        testObject.purgeLogs()
        expectation = XCTestExpectation(description: "Logs should purge before second write")
        pollForPurgeCompletion(urls: expectedPaths, expectation: expectation)
        wait(for: [expectation], timeout: 20)

        testObject.log(.debug, "After purge")
        testObject.log(.info, "After purge")
        
        // Verify that log files contains exactly 2 lines
        expectedMessages = ["After purge", "After purge"]
        expectation = XCTestExpectation(description: "Should receive logs: \(expectedMessages.joined(separator: ", "))")
        pollForLogCompletion(delegate: testObject, expectedMessages: expectedMessages, expectation: expectation)
        wait(for: [expectation], timeout: Double(expectedMessages.count) * 6.0)

        // Verify that actual log files paths same as expected
        expectedPaths = FileTestsHelper.getPaths(testObject: testObject)
        actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, expectedPaths)
        
        testObject.purgeLogs()
        expectation = XCTestExpectation(description: "Logs should purge on completion")
        pollForPurgeCompletion(urls: expectedPaths, expectation: expectation)
        wait(for: [expectation], timeout: 20)
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
        var expectedMessages = ["log 1", "log 1", "log 2", "log 2", "log 3", "log 3", "log 4", "log 4", "log 5", "log 5"]
        var expectation = XCTestExpectation(description: "Should receive logs: \(expectedMessages.joined(separator: ", "))")
        pollForLogCompletion(delegate: testObject, expectedMessages: expectedMessages, expectation: expectation)
        wait(for: [expectation], timeout: Double(expectedMessages.count) * 6.0)

        // Verify that actual log files paths are same as expected
        var expectedPaths = Set(FileTestsHelper.getPaths(testObject: testObject, withArchived: true))
        var actualPaths = Set(testObject.getLogPaths())
        XCTAssertEqual(actualPaths, expectedPaths)

        testObject.purgeLogs()
        expectation = XCTestExpectation(description: "Logs should purge before second write")
        pollForPurgeCompletion(urls: Array(expectedPaths), expectation: expectation)
        wait(for: [expectation], timeout: 20)

        testObject.log(.debug, "After purge")
        testObject.log(.info, "After purge")
        
        expectedMessages = ["After purge", "After purge"]
        expectation = XCTestExpectation(description: "Should receive logs: \(expectedMessages.joined(separator: ", "))")
        pollForLogCompletion(delegate: testObject, expectedMessages: expectedMessages, expectation: expectation)
        wait(for: [expectation], timeout: Double(expectedMessages.count) * 6.0)

        // Verify that actual log files paths are same as expected
        expectedPaths = Set(FileTestsHelper.getPaths(testObject: testObject, withArchived: true))
        actualPaths = Set(testObject.getLogPaths())
        XCTAssertEqual(actualPaths, expectedPaths)
        
        testObject.purgeLogs()
        expectation = XCTestExpectation(description: "Logs should purge on completion")
        pollForPurgeCompletion(urls: Array(expectedPaths), expectation: expectation)
        wait(for: [expectation], timeout: 20)
    }
    
    private func pollForLogCompletion(delegate: FileLoggerDelegate, expectedMessages: [String], expectation: XCTestExpectation) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 3) {
            delegate.getLogs { result in
                let messages: [String] = result.flatMap { log -> [String] in
                    guard let logString = String(data: log, encoding: .utf8) else {
                        return []
                    }
                    
                    return logString.split(separator: "\n").map { String($0) }
                }
                
                if messages.count >= expectedMessages.count {
                    for (index, message) in messages.prefix(expectedMessages.count).enumerated() {
                        if !message.contains(expectedMessages[index]) {
                            XCTFail("Expected log message containing: \(expectedMessages[index]), but received: \(message)")
                        }
                    }

                    expectation.fulfill()
                    return
                }
                
                self.pollForLogCompletion(delegate: delegate, expectedMessages: expectedMessages, expectation: expectation)
            }
        }
    }
    
    private func pollForPurgeCompletion(urls: [URL], expectation: XCTestExpectation) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 4) {
            let fileManager = FileManager.default
            for url in urls {
                if fileManager.fileExists(atPath: url.path) {
                    self.pollForPurgeCompletion(urls: urls, expectation: expectation)
                    return
                }
            }
            expectation.fulfill()
        }
    }
}
