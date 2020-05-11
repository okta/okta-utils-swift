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
}



