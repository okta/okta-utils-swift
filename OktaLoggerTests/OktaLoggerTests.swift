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
        let logger = OktaLogger()
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
        let logger = OktaLogger()
        let destination = MockLoggerDestination()
        logger.addDestination(destination)
        logger.queue.sync {}
        XCTAssertEqual(logger.destinations.count, 1)
        
        let line = (#line + 1) as NSNumber // expected line number of the log
        logger.info(eventName: "hello", message: "world", properties: ["key":"value"])
        logger.queue.sync {}
        XCTAssertEqual(destination.events.count, 1)
        let event = destination.events.first
        XCTAssertNotNil(event)
        XCTAssertEqual(event?.name, "hello")
        XCTAssertEqual(event?.message, "world")
        XCTAssertEqual(event?.properties as! [String:String], ["key":"value"])
        XCTAssertEqual(event?.line, line)
        XCTAssertEqual(event?.file, #file)
        XCTAssertEqual(event?.funcName, #function)
    }
}



