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
@testable import LoggerCore
@testable import FileLogger

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
}
