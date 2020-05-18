import XCTest
@testable import OktaLogger

class OktaConsoleLoggerTests: XCTestCase {
    
    /**
     Verify that logging to the console works as expected
     */
    func testLogToConsoleSyntax() {
        let console = OktaConsoleLogger(identifier: "hello.my.console", level: .debug, defaultProperties: nil)
        let logger = OktaLogger(destinations: [console])
        logger.debug(eventName: "Hello", message: "World")
    }
    
    /**
     Verify that multithreaded logs work correctly on the console
     */
    func testMultithreadingLogToConsole() {
        let expectation = XCTestExpectation(description: "all logging complete")
        let destination = OktaConsoleLogger(identifier: "hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])

        var completed = 0
        let threads = 1000
        let serialQueue = DispatchQueue(label: "serial")
        let concQueue = DispatchQueue(label: "hello", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        for i in 0..<threads {
            concQueue.async {
                logger.debug(eventName: "\(i)", message: "Thread count: \(i)")
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
