import XCTest
@testable import OktaLogger

class OktaConsoleLoggerTests: XCTestCase {
    
    /**
     Verify that logging to the console works as expected
     */
    func testLogToConsoleSyntax() {
        let console = OktaConsoleLogger(identifier: "hello.my.console", level: .debug, console: false)
        let logger = OktaLogger(destinations: [console])
        logger.debug(eventName: "Hello", message: "World", properties: nil)
    }
}
