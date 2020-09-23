//
//  OktaLoggerDefaultPropertiesTests.swift
//  OktaLoggerTests
//
//  Created by Lihao Li on 9/21/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import XCTest
@testable import OktaLogger

class OktaLoggerDefaultPropertiesTests: XCTestCase {
    func testNoDefaultPropertyInInitializer() {
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        XCTAssertNotNil(consoleLogger.defaultProperties)
        XCTAssertTrue(consoleLogger.defaultProperties.isEmpty)

        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        XCTAssertNotNil(fileLogger.defaultProperties)
        XCTAssertTrue(fileLogger.defaultProperties.isEmpty)
    }

    func testDefaultPropertiesInInitializer() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: dict)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])

        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: dict)
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])
    }

    func testAddDefaultPropertiesWithNilIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: nil)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])
    }

    func testAddDefaultPropertiesWithValidIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: ["com.okta.consoleLogger"])
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertTrue(fileLogger.defaultProperties.isEmpty)
    }

    func testAddDefaultPropertiesWithInValidIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: ["com.okta.inValidIdentifier"])
        XCTAssertTrue(consoleLogger.defaultProperties.isEmpty)
        XCTAssertTrue(fileLogger.defaultProperties.isEmpty)
    }

    func testUpdateDefaultPropertiesWithNilIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: nil)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])

        logger.addDefaultProperties(["testKey3": "testValue4"], identifiers: nil)
        let res = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue4"]
        XCTAssertEqual(res, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(res, fileLogger.defaultProperties as? [String: String])
    }

    func testUpdateDefaultPropertiesWithValidIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: nil)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])

        logger.addDefaultProperties(["testKey3": "testValue4"], identifiers: ["com.okta.consoleLogger"])
        let res = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue4"]
        XCTAssertEqual(res, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])
    }

    func testUpdateDefaultPropertiesWithInValidIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: nil)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])

        logger.addDefaultProperties(["testKey3": "testValue4"], identifiers: ["com.okta.inValidIdentifier"])
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])
    }

    func testRemoveDefaultPropertiesWithNilIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: nil)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])

        logger.removeDefaultProperties(for: "testKey1", identifiers: nil)
        let res = ["testKey2": "testValue2", "testKey3": "testValue3"]
        XCTAssertEqual(res, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(res, fileLogger.defaultProperties as? [String: String])
    }

    func testRemoveDefaultPropertiesWithValidIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: nil)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])

        logger.removeDefaultProperties(for: "testKey1", identifiers: ["com.okta.fileLogger"])
        let res = ["testKey2": "testValue2", "testKey3": "testValue3"]
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(res, fileLogger.defaultProperties as? [String: String])
    }

    func testRemoveDefaultPropertiesWithInValidIdentifier() {
        let dict = ["testKey1": "testValue1", "testKey2": "testValue2", "testKey3": "testValue3"]
        let consoleLogger = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let fileLogger = OktaLoggerFileLogger(identifier: "com.okta.fileLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [consoleLogger, fileLogger])
        logger.addDefaultProperties(dict, identifiers: nil)
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])

        logger.removeDefaultProperties(for: "testKey1", identifiers: ["com.okta.inValidIdentifier"])
        XCTAssertEqual(dict, consoleLogger.defaultProperties as? [String: String])
        XCTAssertEqual(dict, fileLogger.defaultProperties as? [String: String])
    }

    func testMultithreadingAddDefaultPropertiesAndLogToConsole() {
        let expectation = XCTestExpectation(description: "all logging complete")
        let destination = OktaLoggerConsoleLogger(identifier: "com.okta.consoleLogger", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])

        var completed = 0
        let threads = 1000
        let serialQueue = DispatchQueue(label: "com.okta.serialQueue")
        let concurrentQueue = DispatchQueue(label: "com.okta.concurrentQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        for i in 0..<threads {
            concurrentQueue.async {
                logger.addDefaultProperties(["testKey1": "testValue1"], identifiers: nil)
                logger.debug(eventName: "\(i)", message: "Thread count: \(i)")
                logger.removeDefaultProperties(for: "testKey1", identifiers: nil)
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
