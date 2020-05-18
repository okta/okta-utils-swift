import XCTest
@testable import OktaLogger

class OktaLoggerTests: XCTestCase {
    
    /**
     Verify that the Okta Log levels are correctly oriented
     */
    func testLogLevelRawValues() {
        XCTAssertTrue(OktaLogLevel.error.rawValue > OktaLogLevel.uiEvent.rawValue)
        XCTAssertTrue(OktaLogLevel.uiEvent.rawValue > OktaLogLevel.warning.rawValue)
        XCTAssertTrue(OktaLogLevel.warning.rawValue > OktaLogLevel.info.rawValue)
        XCTAssertTrue(OktaLogLevel.info.rawValue > OktaLogLevel.debug.rawValue)
        XCTAssertTrue(OktaLogLevel.debug.rawValue > OktaLogLevel.off.rawValue)
        XCTAssertEqual(OktaLogLevel.off.rawValue, 0)
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
        let destination = MockLoggerDestination()
        let logger = OktaLogger(destinations: [destination])
        XCTAssertEqual(logger.destinations.count, 1)
        
        let line = (#line + 1) as NSNumber // expected line number of the log
        logger.info(eventName: "hello", message: "world", properties: ["key":"value"])
        XCTAssertEqual(destination.events.count, 1)
        let event = destination.events.first
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.name, "hello")
        XCTAssertEqual(event?.message, "world")
        XCTAssertEqual(event?.properties as? [String:String], ["key":"value"])
        XCTAssertEqual(event?.line, line)
        XCTAssertEqual(event?.file, #file)
        XCTAssertEqual(event?.funcName, #function)
    }
    
    /**
     Verify that nil properties pick up the defaults, but explicitly set properties override
     */
//    func testDefaultProperties() {
//        let destination = MockLoggerDestination()
//        let logger = OktaLogger(destinations: [destination])
//        var properties = ["key":"value"]
//        logger.setDefaultProperties(properties: properties)
//        logger.addDestination(destination)
//        logger.info(eventName: "hello", message: "world", properties: nil)
//
//        XCTAssertEqual(destination.events.count, 1)
//        var event = destination.events.first
//        XCTAssertNotNil(event)
//        XCTAssertEqual(event?.properties as? [String:String], properties)
//        
//        properties = ["override":"values"]
//        logger.info(eventName: "hello", message: "world", properties: properties)
//        XCTAssertEqual(destination.events.count, 2)
//        event = destination.events.last
//        XCTAssertNotNil(event)
//        XCTAssertEqual(event?.properties as? [String:String], properties)
//    }
    
    /**
     Verify that the logging level is honored when logging
     */
    func testLoggingLevel() {
        let destination = MockLoggerDestination()
        destination.level = .info
        let logger = OktaLogger(destinations: [destination])
        logger.debug(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.events.count, 0)
        logger.info(eventName: "hello", message: "world", properties: nil)
        XCTAssertEqual(destination.events.count, 1)
    }
}



