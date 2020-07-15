import XCTest
@testable import OktaLogger

class OktaLoggerConsoleLoggerTests: XCTestCase {
    
    /**
     Verify that logging to the console works as expected
     */
    func testLogToConsoleSyntax() {
        let console = OktaLoggerConsoleLogger(identifier: "hello.my.console", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [console])
        logger.debug(eventName: "Hello", message: nil)
        logger.info(eventName: "Boom", message: "crash", properties: ["what":"ever"])
        logger.error(eventName: "Boom", message: "crash", properties: ["what":"ever"])
        logger.warning(eventName: "Boom", message: "crash", properties: ["what":"ever"])
        logger.uiEvent(eventName: "Boom", message: "crash", properties: ["what":"ever"])
        logger.debug(eventName: "hello", message: "bogusness", properties: nil, file: "")
        logger.log(level: .off, eventName: "none", message: nil, properties: nil)
    }
    
    /**
     Verify that multithreaded logs work correctly on the console
     */
    func testMultithreadingLogToConsole() {
        let expectation = XCTestExpectation(description: "all logging complete")
        let destination = OktaLoggerConsoleLogger(identifier: "hello.world", level: .all, defaultProperties: nil)
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
    
    func testFileLogger() {
        let destination:OktaLoggerFileLogger = OktaLoggerFileLogger(identifier: "hello.world", level: .all, defaultProperties: nil)
        let logger = OktaLogger(destinations: [destination])
        logger.debug(eventName: "event", message: "Message")
        let path:String = destination.logDirectoryAbsolutePath()!
        print(path)
        var logs:[NSData] = destination.getLogs()
        XCTAssertEqual(logs.count, 1)
        var data=String(NSString(data:logs[0] as Data,encoding: String.Encoding.utf8.rawValue)!)
        XCTAssertNotNil(data)
        print(data)
        destination.resetLogging()
        logger.debug(eventName: "new Log", message: "new log message")
        logs = destination.getLogs()
        XCTAssertEqual(logs.count, 1)
        data=String(NSString(data:logs[0] as Data,encoding: String.Encoding.utf8.rawValue)!)
        print(data)
    }
}
