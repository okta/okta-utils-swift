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

class OktaLoggerTests: XCTestCase {

    // MARK: - Test log operations

    /**
     Verify that the Okta Log levels are correctly oriented
     */
    func testLogLevelRawValues() {
        XCTAssertEqual(OktaLoggerLogLevel.off.rawValue, 0)
        XCTAssertEqual(OktaLoggerLogLevel.error.rawValue, 1 << 4)
        XCTAssertEqual(OktaLoggerLogLevel.uiEvent.rawValue, OktaLoggerLogLevel.error.rawValue | 1 << 3)
        XCTAssertEqual(OktaLoggerLogLevel.warning.rawValue, OktaLoggerLogLevel.uiEvent.rawValue | 1 << 2)
        XCTAssertEqual(OktaLoggerLogLevel.info.rawValue, OktaLoggerLogLevel.warning.rawValue | 1 << 1)
        XCTAssertEqual(OktaLoggerLogLevel.debug.rawValue, OktaLoggerLogLevel.info.rawValue | 1 << 0)
    }

    /**
     Test out the basic logging syntax
     */
    func testLoggingSyntax() {
        let logger = OktaLogger(destinations: [])
        logger.debug(eventName: "hello", message: "world", properties: nil)
        logger.info(eventName: "hello", message: "world", properties: nil)
        logger.warning(eventName: "hello", message: "world", properties: nil)
        logger.uiEvent(eventName: "hello", message: "world", properties: nil)
        logger.error(eventName: "hello", message: "world", properties: nil)
    }

    /**
     Verify that the mock destination picks up the event as expected
     */
    func testSingleMockDestinationEvent() {
        let destination = MockLoggerDestination(identifier: "Hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])
        XCTAssertEqual(logger.destinations.count, 1)

        let line = (#line + 1) as NSNumber // expected line number of the log
        logger.info(eventName: "hello", message: "world", properties: ["key": "value"])
        XCTAssertEqual(destination.events.count, 1)
        let event = destination.events.first
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.name, "hello")
        XCTAssertEqual(event?.message, "world")
        XCTAssertEqual(event?.properties as? [String: String], ["key": "value"])
        XCTAssertEqual(event?.line, line)
        XCTAssertEqual(event?.file, #file)
        XCTAssertEqual(event?.funcName, #function)
    }

    /**
     Verify that the mock destination handles NSError event as expected
     */
    func testNSErrorEventLog() {
        let destination = MockLoggerDestination(identifier: "Hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])
        XCTAssertEqual(logger.destinations.count, 1)

        let line = (#line + 1) as NSNumber // expected line number of the log
        logger.log(error: NSError(domain: "com.okta.logger.test", code: 1001, userInfo: ["key": "value"]))
        XCTAssertEqual(destination.events.count, 1)
        let event = destination.events.first
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.name, "Error com.okta.logger.test 1001")
        XCTAssertNil(event?.message)
        XCTAssertEqual(event?.properties as? [String: String], ["key": "value"])
        XCTAssertEqual(event?.line, line)
        XCTAssertEqual(event?.file, #file)
        XCTAssertEqual(event?.funcName, #function)
    }

    // MARK: - Test default properties updating

    /**
     Verify that nil properties pick up the default properties for the destination
     but explicitly set properties override them.
     */
    func testDefaultProperties() {
        var properties = ["key": "value"]
        let destination = MockLoggerDestination(identifier: "com.mock", level: .all, defaultProperties: properties)
        let logger = OktaLogger(destinations: [destination])
        logger.info(eventName: "hello", message: "world", properties: nil)

        XCTAssertEqual(destination.events.count, 1)
        var event = destination.events.first
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.properties as? [String: String], properties)

        properties = ["override": "values"]
        logger.info(eventName: "hello", message: "world", properties: properties)
        XCTAssertEqual(destination.events.count, 2)
        event = destination.events.last
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.properties as? [String: String], properties)
    }

    /**
     Verify that default properties have the correct format and order in the log message.
     */
    func testDefaultPropertiesMessage() {
        let properties = ["A": "value 1", "B": "value 2", "C": "value 3"]
        let expectedMessage = "A: value 1; B: value 2; C: value 3"
        let destination = MockLoggerDestination(identifier: "test", level: .all, defaultProperties: properties)
        let logger = OktaLogger(destinations: [destination])

        for _ in 0..<20 {
            logger.info(eventName: "hello", message: "world", properties: nil)
        }

        XCTAssertEqual(destination.eventMessages.count, 20)
        destination.eventMessages.forEach {
            XCTAssertTrue($0.contains(expectedMessage))
        }
    }

    /**
     Verify that log message is correct after updating default properties.
     */
    func testDefaultPropertiesChange() {
        let properties = ["A": "value 1", "B": "value 2"]
        let destination = MockLoggerDestination(identifier: "test", level: .all, defaultProperties: properties)
        let logger = OktaLogger(destinations: [destination])

        logger.info(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.eventMessages.count, 1)
        XCTAssertTrue(destination.eventMessages[0].contains("\"A: value 1; B: value 2\""))

        destination.addDefaultProperties(["B": "value 3", "C": "value 4"])
        logger.info(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.eventMessages.count, 2)
        XCTAssertTrue(destination.eventMessages[1].contains("\"A: value 1; B: value 3; C: value 4\""))

        destination.removeDefaultProperties(for: "B")
        logger.info(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.eventMessages.count, 3)
        XCTAssertTrue(destination.eventMessages[2].contains("\"A: value 1; C: value 4\""))

        destination.defaultProperties = ["D": "value 5", "E": "value 6"]
        logger.info(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.eventMessages.count, 4)
        XCTAssertTrue(destination.eventMessages[3].contains("\"D: value 5; E: value 6\""))
    }

    // MARK: - Test logging level updating

    /**
     Verify that the logging level is honored when logging
     */
    func testLoggingLevels() {
        let destination = MockLoggerDestination(identifier: "hello.world", level: .info, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])
        logger.debug(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.events.count, 0) // not incremented
        logger.info(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.events.count, 1) // incremented

        // modify the logger level vie the setLogLevel() api
        logger.setLogLevel(level: .error, identifiers: [destination.identifier])
        logger.info(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.events.count, 1) // not incremented
        logger.error(eventName: "error", message: nil)
        XCTAssertEqual(destination.events.count, 2) // incremented

        // set the logger level to a bogus identifier, should be ignored
        logger.setLogLevel(level: .debug, identifiers: ["bogus.identifier"])
        logger.debug(eventName: "boom", message: nil)
        XCTAssertEqual(destination.events.count, 2) // not incremented
    }

    /**
     Verify that massive multithreading along with log level setting does not break
     */
    func testMassiveMultithreading() {

        var expectation = XCTestExpectation(description: "all logging complete")
        let destination = MockLoggerDestination(identifier: "hello.world", level: .all, defaultProperties: nil)
        var logger = OktaLogger(destinations: [destination])

        var completed = 0
        let threads = 1000
        let serialQueue = DispatchQueue(label: "serial")
        let concQueue = DispatchQueue(label: "hello", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        for i in 0..<threads {
            concQueue.async {
                logger.debug(eventName: "\(i)", message: "Thread count: \(i)")
                serialQueue.sync {
                    completed += 1
                    if completed == threads {
                        expectation.fulfill()
                    }
                }
            }
            concQueue.async {
                logger.setLogLevel(level: .all, identifiers: [destination.identifier])
            }
            concQueue.async {
                logger.setLogLevel(level: .debug, identifiers: [destination.identifier])
            }
            concQueue.async {
                logger.setLogLevel(level: [.info, .debug, .error], identifiers: [destination.identifier])
            }
        }

        self.wait(for: [expectation], timeout: 10)
        let events = destination.events
        XCTAssertEqual(events.count, threads)

        // Delete and recreate the logger instance many times throughout the test
        completed = 0
        expectation = XCTestExpectation(description: "all logging complete")
        for i in 0..<threads {
            concQueue.async {
                logger.debug(eventName: "\(i)", message: "Thread count: \(i)")
            }
            concQueue.async {
                logger.setLogLevel(level: .all, identifiers: [destination.identifier])
            }

            if i % 10 == 0 {
                concQueue.async {
                    // update logger to new instance
                    DispatchQueue.main.async {
                        let dest = MockLoggerDestination(identifier: UUID().uuidString, level: .all, defaultProperties: nil)
                        logger = OktaLogger(destinations: [dest])
                    }
                }
            }
            concQueue.async {
                logger.setLogLevel(level: [.info, .debug, .error], identifiers: [destination.identifier])
            }

            serialQueue.async {
                completed += 1
                if completed == threads {
                    expectation.fulfill()
                }
            }
        }
        self.wait(for: [expectation], timeout: 10)
    }

    func testDestinationBase() {
        let destination = OktaLoggerDestinationBase(identifier: "hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])
        logger.debug(eventName: "hello", message: nil)
    }

    // MARK: - Test add/remove destinations

    /**
     Verify that new destinations could be added to a logger instance.
     */
    func testAddDestination() {
        let oktaLogger = OktaLogger()

        XCTAssertTrue(oktaLogger.destinations.isEmpty)
        oktaLogger.addDestination(OktaLoggerDestinationBase(identifier: "test1", level: .all, defaultProperties: nil))
        oktaLogger.addDestination(OktaLoggerDestinationBase(identifier: "test2", level: .all, defaultProperties: nil))

        XCTAssertEqual(oktaLogger.destinations.count, 2)
        XCTAssertNotNil(oktaLogger.destinations["test1"])
        XCTAssertNotNil(oktaLogger.destinations["test2"])
    }

    /**
     Verify that destination with duplicating ID won't be added.
     */
    func testAddDestinationWithDuplicatingId() {
        let destination = OktaLoggerDestinationBase(identifier: "test1", level: .all, defaultProperties: nil)
        let oktaLogger = OktaLogger(destinations: [destination])

        XCTAssertEqual(oktaLogger.destinations.count, 1)
        oktaLogger.addDestination(OktaLoggerDestinationBase(identifier: "test1", level: .all, defaultProperties: nil))

        XCTAssertEqual(oktaLogger.destinations.count, 1)
        XCTAssertTrue(oktaLogger.destinations["test1"] === destination)
    }

    /**
     Verify that destination can be removed from logger instance.
     */
    func testRemoveDestination() {
        let oktaLogger = OktaLogger(destinations: [
            OktaLoggerDestinationBase(identifier: "test1", level: .all, defaultProperties: nil),
            OktaLoggerDestinationBase(identifier: "test2", level: .all, defaultProperties: nil),
            OktaLoggerDestinationBase(identifier: "test3", level: .all, defaultProperties: nil)
        ])

        XCTAssertEqual(oktaLogger.destinations.count, 3)
        oktaLogger.removeDestination(withIdentifier: "test1")
        oktaLogger.removeDestination(withIdentifier: "test2")

        XCTAssertEqual(oktaLogger.destinations.count, 1)
        XCTAssertNil(oktaLogger.destinations["test1"])
        XCTAssertNil(oktaLogger.destinations["test2"])
        XCTAssertNotNil(oktaLogger.destinations["test3"])
    }

    /**
     Verify that attempt to removing nonexistent destination won't cause any issues.
     */
    func testRemoveDestinationWithNonexistentId() {
        let oktaLogger = OktaLogger(destinations: [
            OktaLoggerDestinationBase(identifier: "test1", level: .all, defaultProperties: nil)
        ])

        XCTAssertEqual(oktaLogger.destinations.count, 1)
        oktaLogger.removeDestination(withIdentifier: "test2")

        XCTAssertEqual(oktaLogger.destinations.count, 1)
        XCTAssertNotNil(oktaLogger.destinations["test1"])
    }
}
