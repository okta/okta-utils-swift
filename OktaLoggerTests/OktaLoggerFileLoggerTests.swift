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
        for i in 1...5 {
            logger.debug(eventName: "BEFORE_PURGE", message: "\(i):log message")
        }

        var logs = testObject.getLogs()
        var data = logs[0] as Data
        let lineCount = countLines(data)
        XCTAssertEqual(lineCount, 5)
        testObject.purgeLogs()

        logger.debug(eventName: "AFTER_PURGE", message: "Debug log")
        logger.info(eventName: "AFTER_PURGE", message: "Debug log")
        // new logs dont get immediately to disk written after rolling. We can force flush destination to write to file. Or wait few moments
        logs = testObject.getLogs()
        data = logs[0] as Data
        let newLineCount = countLines(data)
        XCTAssertEqual(newLineCount, 2)
    }

    func testLumberjackFileLogger() {

        let logConfig = OktaLoggerFileLoggerConfig(rollingFrequency: TWO_DAYS)
        let testObject = LumberjackLoggerDelegate(logConfig)

        // default rolling frequency
        XCTAssertEqual(testObject.fileLogger.rollingFrequency, TWO_DAYS)
        XCTAssertNotNil(testObject.directoryPath())

        XCTAssertEqual(testObject.logsCanBePurged(), true)
        for i in 1...5 {
            testObject.log(.debug, "log \(i)")
        }

        var logs = testObject.getLogs()
        var data = logs[0] as Data
        let lineCount = countLines(data)
        XCTAssertEqual(lineCount, 5)
        testObject.purgeLogs()

        testObject.log(.debug, "After purge")
        testObject.log(.info, "After purge")
        // new logs dont get immediately to disk written after rolling. We can force flush destination to write to file. Or wait few moments
        logs = testObject.getLogs()
        data = logs[0] as Data
        let newLineCount = countLines(data)
        XCTAssertEqual(newLineCount, 2)
    }

    func countLines(_ data: Data) -> Int {
        let logData = String(data: data as Data, encoding: .utf8)
        var lineCount: Int = 0
        logData?.enumerateLines { (_, _) in
            lineCount += 1
        }
        return lineCount
    }
}
