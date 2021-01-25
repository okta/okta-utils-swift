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
    let TWO_DAYS = TimeInterval(48 * 60 * 60)

    func testOktaFileLogger() {
        let testObject: OktaLoggerFileLogger = OktaLoggerFileLogger(identifier: "hello.world", level: .all, defaultProperties: nil)
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
        XCTAssertEqual(countLines(logs[0]), 5)
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
        XCTAssertEqual(countLines(logs[0]), 2)
        testObject.purgeLogs()
    }

    func testLumberjackFileLogger() {

        let logConfig = OktaLoggerFileLoggerConfig()
        logConfig.rollingFrequency = TWO_DAYS
        let testObject = LumberjackLoggerDelegate(logConfig)

        // default rolling frequency
        XCTAssertEqual(testObject.fileLogger.rollingFrequency, TWO_DAYS)
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
        XCTAssertEqual(countLines(logs[0]), 5)

        // Verify that actual log files paths same as expected
        var extectedPaths = getPaths(testObject: testObject)
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
        XCTAssertEqual(countLines(logs[0]), 2)

        // Verify that actual log files paths same as expected
        extectedPaths = getPaths(testObject: testObject)
        actualPaths = testObject.getLogPaths()
        XCTAssertEqual(actualPaths, extectedPaths)
        testObject.purgeLogs()
    }

    func testReadMultithreading() {
        let testObject = LumberjackLoggerDelegate(.init())
        testObject.purgeLogs()
        let iterationsCount = 100

        let testFinishExpectation = XCTestExpectation(description: "All read/write operations finished")
        testFinishExpectation.expectedFulfillmentCount = 200
        for _ in 0..<iterationsCount {
            DispatchQueue.global(qos: .default).async {
                testObject.log(.debug, "Debug message")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                _ = testObject.getLogs()
                testFinishExpectation.fulfill()
            }
        }
        wait(for: [testFinishExpectation], timeout: 30.0)

        let actualLogs = testObject.getLogs()
        XCTAssertEqual(actualLogs.count, 1)
        XCTAssertEqual(countLines(actualLogs[0]), 100)
        testObject.purgeLogs()
    }

    func countLines(_ data: Data) -> Int {
        let logData = String(data: data as Data, encoding: .utf8)
        var lineCount: Int = 0
        logData?.enumerateLines { (_, _) in
            lineCount += 1
        }
        return lineCount
    }

    private func getPaths(testObject: LumberjackLoggerDelegate) -> [URL] {
        let logFileInfos = testObject.fileLogger.logFileManager.sortedLogFileInfos
        var logFilePathArray = [URL]()
        for logFileInfo in logFileInfos {
            if logFileInfo.isArchived {
                continue
            }
            let logFilePath = logFileInfo.filePath
            let fileURL = URL(fileURLWithPath: logFilePath)
            if let _ = try? Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe) {
                logFilePathArray.insert(fileURL, at: 0)
            }
        }
        return logFilePathArray
    }
}
