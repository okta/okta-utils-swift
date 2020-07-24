import XCTest
@testable import OktaLogger

class OktaLoggerTests: XCTestCase {

    /**
     Verify that the Okta Log levels are correctly oriented
     */
    func testLogLevelRawValues() {
        XCTAssertTrue(OktaLoggerLogLevel.error.rawValue > OktaLoggerLogLevel.uiEvent.rawValue)
        XCTAssertTrue(OktaLoggerLogLevel.uiEvent.rawValue > OktaLoggerLogLevel.warning.rawValue)
        XCTAssertTrue(OktaLoggerLogLevel.warning.rawValue > OktaLoggerLogLevel.info.rawValue)
        XCTAssertTrue(OktaLoggerLogLevel.info.rawValue > OktaLoggerLogLevel.debug.rawValue)
        XCTAssertTrue(OktaLoggerLogLevel.debug.rawValue > OktaLoggerLogLevel.off.rawValue)
        XCTAssertEqual(OktaLoggerLogLevel.off.rawValue, 0)
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

    /**
     Verify that the 'main' logger getters and setters work properly.
     */
    func testGlobalLogger() {
        let destination = MockLoggerDestination(identifier: "hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])
        OktaLogger.main = logger
        XCTAssertEqual(logger, OktaLogger.main)
        OktaLogger.main?.debug(eventName: "Main", message: nil)
        XCTAssertEqual(destination.events.count, 1)
    }

    func testDestinationBase() {
        let destination = OktaLoggerDestinationBase(identifier: "hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])
        logger.debug(eventName: "hello", message: nil)
    }
}
