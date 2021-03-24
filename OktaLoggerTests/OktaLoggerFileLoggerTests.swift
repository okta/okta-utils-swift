//
//  OktaLoggerFileLoggerTests.swift
//  OktaLoggerTests
//
//  Created by Kaushik Krishnakumar on 7/15/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

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
        wait(for: [receiveLogsExpectation], timeout: 5.0)
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
        wait(for: [receiveLogsExpectation], timeout: 5.0)
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
        wait(for: [receiveLogsExpectation], timeout: 5.0)
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
        wait(for: [receiveLogsExpectation], timeout: 5.0)
        XCTAssertEqual(FileTestsHelper.countLines(logs[0]), 2)

        // Verify that actual log files paths same as expected
        extectedPaths = FileTestsHelper.getPaths(testObject: testObject)
        actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, extectedPaths)
        testObject.purgeLogs()
    }
}
