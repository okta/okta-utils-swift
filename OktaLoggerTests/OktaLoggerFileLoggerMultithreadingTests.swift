//
//  OktaLoggerFileLoggerMultithreadingTests.swift
//  OktaLoggerTests
//
//  Created by Borys Kasianenko on 3/24/21.
//  Copyright © 2021 Okta, Inc. All rights reserved.
//

import XCTest
@testable import OktaLogger

class OktaLoggerFileLoggerMultithreadingTests: XCTestCase {

    private var lumberjackDelegate: LumberjackLoggerDelegate!
    private let defaultIterationsCount = 100
    private let defaultTimeout: TimeInterval = 20.0

    override func setUp() {
        super.setUp()
        lumberjackDelegate = LumberjackLoggerDelegate(FileTestsHelper.defaultFileConfig)
    }

    override class func tearDown() {
        FileTestsHelper.cleanUpLogs()
    }

    /**
     Verify that LumberjackLogger delegate can read and write logs simultaneously.
     */
    func testLogAndReadMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "All read/write operations finished")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for _ in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.lumberjackDelegate.log(.debug, "Debug message\n")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                _ = self.lumberjackDelegate.getLogs()
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        let actualLogs = lumberjackDelegate.getLogs()
        XCTAssertEqual(actualLogs.count, 1)
        XCTAssertEqual(FileTestsHelper.countLines(actualLogs[0]), defaultIterationsCount)
    }

    /**
     Verify that LumberjackLogger delegate can write and purge logs simultaneously.
     */
    func testLogAndPurgeMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "All write/purge operations finished")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for _ in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.lumberjackDelegate.log(.debug, "Debug message")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                self.lumberjackDelegate.purgeLogs()
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        lumberjackDelegate.purgeLogs()
        XCTAssertTrue(lumberjackDelegate.getLogs().isEmpty)
    }
}
