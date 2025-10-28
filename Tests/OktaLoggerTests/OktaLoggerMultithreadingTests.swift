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
#if SWIFT_PACKAGE
@testable import LoggerCore
#endif

class OktaLoggerMultithreadingTests: XCTestCase {

    private var oktaLogger: OktaLogger!
    private let defaultIterationsCount = 100
    private let defaultTimeout: TimeInterval = 20.0

    override func setUp() {
        super.setUp()
        oktaLogger = OktaLogger()
    }

    // MARK: - Logging tests

    /**
     Verify that OktaLogger can process log messages from different threads simultaneously.
     */
    func testLogEventMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount

        let destination1 = MockLoggerDestination(identifier: "test1", level: .all, defaultProperties: nil)
        let destination2 = MockLoggerDestination(identifier: "test2", level: .all, defaultProperties: nil)
        oktaLogger.addDestination(destination1)
        oktaLogger.addDestination(destination2)

        for _ in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.info(eventName: "Info event", message: nil)
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        XCTAssertEqual(destination1.eventMessages.count, defaultIterationsCount)
        XCTAssertEqual(destination2.eventMessages.count, defaultIterationsCount)
    }

    /**
     Verify that log messages can be processed simultaneously with changing destinations.
     This test will cause crash if `destinations` property accessed without read lock.
     */
    func testLogEventWithMutatingDestinationsMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for index in 0..<defaultIterationsCount {
            oktaLogger.addDestination(testDestination(identifier: "test\(index)"))
        }

        for iteration in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.removeDestination(withIdentifier: "test\(iteration)")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.info(eventName: "Info event", message: nil)
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        XCTAssertTrue(oktaLogger.destinations.isEmpty)
    }

    /**
     Verify that OktaLogger can process error messages from different threads simultaneously.
     */
    func testLogErrorMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount

        let destination1 = MockLoggerDestination(identifier: "test1", level: .all, defaultProperties: nil)
        let destination2 = MockLoggerDestination(identifier: "test2", level: .all, defaultProperties: nil)
        oktaLogger.addDestination(destination1)
        oktaLogger.addDestination(destination2)

        for _ in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.log(error: NSError(domain: "test", code: 0, userInfo: nil))
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        XCTAssertEqual(destination1.events.count, defaultIterationsCount)
        XCTAssertEqual(destination2.events.count, defaultIterationsCount)
    }

    /**
     Verify that error messages can be processed simultaneously with changing destinations.
     This test will cause crash if `destinations` property accessed without read lock.
     */
    func testLogErrorWithMutatingDestinationsMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for index in 0..<defaultIterationsCount {
            oktaLogger.addDestination(testDestination(identifier: "test\(index)"))
        }

        for iteration in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.removeDestination(withIdentifier: "test\(iteration)")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.log(error: NSError(domain: "test", code: 0, userInfo: nil))
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        XCTAssertTrue(oktaLogger.destinations.isEmpty)
    }

    // MARK: - Log level modification

    /**
     Verify that logging level can be changed simultaneously with changing destinations from the different thread.
     This test will cause crash if `destinations` property accessed without read lock.
     */
    func testChangeLogLevelMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for index in 0..<defaultIterationsCount {
            oktaLogger.addDestination(testDestination(identifier: "test\(index)"))
        }

        for iteration in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.removeDestination(withIdentifier: "test\(iteration)")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.setLogLevel(level: .info, identifiers: ["test\(iteration)"])
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        XCTAssertTrue(oktaLogger.destinations.isEmpty)
    }

    // MARK: - Destinations modification

    /**
     Verify that destinations could be added from different threads simultaneously.
     This test will cause crash if `destinations` property accessed without write lock.
     */
    func testAddDestinationsMultithreading() {
        let addDestinationsExpectation = XCTestExpectation(description: "All destinations should be added")
        addDestinationsExpectation.expectedFulfillmentCount = defaultIterationsCount

        for index in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.addDestination(self.testDestination(identifier: "test\(index)"))
                addDestinationsExpectation.fulfill()
            }
        }

        wait(for: [addDestinationsExpectation], timeout: defaultTimeout)
        XCTAssertEqual(oktaLogger.destinations.count, defaultIterationsCount)
    }

    /**
     Verify that destinations could be removed from different threads simultaneously.
     This test will cause crash if `destinations` property accessed without write lock.
     */
    func testRemoveDestinationsMultithreading() {
        let removeDestinationsExpectation = XCTestExpectation(description: "All destinations should be removed")
        removeDestinationsExpectation.expectedFulfillmentCount = defaultIterationsCount

        for index in 0..<defaultIterationsCount {
            oktaLogger.addDestination(testDestination(identifier: "test\(index)"))
        }

        for iteration in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.removeDestination(withIdentifier: "test\(iteration)")
                removeDestinationsExpectation.fulfill()
            }
        }

        wait(for: [removeDestinationsExpectation], timeout: defaultTimeout)
        XCTAssertTrue(oktaLogger.destinations.isEmpty)
    }

    // MARK: - Default properties modification

    /**
     Verify that detault properties can be added simultaneously with changing destinations from the different thread.
     This test will cause crash if `destinations` property accessed without read lock.
     */
    func testAddDefaultPropertiesMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for index in 0..<defaultIterationsCount {
            oktaLogger.addDestination(testDestination(identifier: "test\(index)"))
        }

        for iteration in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.removeDestination(withIdentifier: "test\(iteration)")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.addDefaultProperties(["props\(iteration)": "test"], identifiers: nil)
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        XCTAssertTrue(oktaLogger.destinations.isEmpty)
    }

    /**
     Verify that detault properties could be removed simultaneously with changing destinations from the different thread.
     This test will cause crash if `destinations` property accessed without read lock.
     */
    func testRemoveDefaultPropertiesMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for iteration in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.addDestination(self.testDestinationWithProps(identifier: "test\(iteration)"))
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                self.oktaLogger.removeDefaultProperties(for: "props\(iteration)", identifiers: nil)
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        XCTAssertEqual(oktaLogger.destinations.count, defaultIterationsCount)
    }
}

private extension OktaLoggerMultithreadingTests {

    func testDestination(identifier: String) -> OktaLoggerDestinationProtocol {
        return OktaLoggerDestinationBase(identifier: identifier, level: .all, defaultProperties: nil)
    }

    func testDestinationWithProps(identifier: String) -> OktaLoggerDestinationProtocol {
        return OktaLoggerDestinationBase(identifier: identifier, level: .all, defaultProperties: Self.testDefaultProperties)
    }

    static var testDefaultProperties: [String: String] {
        var result: [String: String] = [:]
        for iteration in 0..<100 {
            result["props\(iteration)"] = "test"
        }
        return result
    }
}
