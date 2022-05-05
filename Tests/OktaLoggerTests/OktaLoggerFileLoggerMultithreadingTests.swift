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
@testable import FileLogger

class OktaLoggerFileLoggerMultithreadingTests: XCTestCase {

    private var lumberjackDelegate: LumberjackLoggerDelegate!
    private let defaultIterationsCount = 100
    private let defaultTimeout: TimeInterval = 20.0

    override func setUp() {
        super.setUp()
        lumberjackDelegate = LumberjackLoggerDelegate(FileTestsHelper.defaultFileConfig)
    }

    override class func tearDown() {
        FileTestsHelper.cleanUpLogs()
    }

    /**
     Verify that LumberjackLogger delegate can read and write logs simultaneously.
     */
    func testLogAndReadMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "All read/write operations finished")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for _ in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.lumberjackDelegate.log(.debug, "Debug message\n")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                _ = self.lumberjackDelegate.getLogs()
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)
        let actualLogs = lumberjackDelegate.getLogs()
        XCTAssertEqual(actualLogs.count, 1)
        XCTAssertEqual(FileTestsHelper.countLines(actualLogs[0]), defaultIterationsCount)
    }

    /**
     Verify that LumberjackLogger delegate can write and purge logs simultaneously.
     */
    func testLogAndPurgeMultithreading() {
        let testFinishExpectation = XCTestExpectation(description: "All write/purge operations finished")
        testFinishExpectation.expectedFulfillmentCount = defaultIterationsCount * 2

        for _ in 0..<defaultIterationsCount {
            DispatchQueue.global(qos: .default).async {
                self.lumberjackDelegate.log(.debug, "Debug message")
                testFinishExpectation.fulfill()
            }
            DispatchQueue.global(qos: .default).async {
                self.lumberjackDelegate.purgeLogs()
                testFinishExpectation.fulfill()
            }
        }

        wait(for: [testFinishExpectation], timeout: defaultTimeout)

        let purgeExpectation = expectation(description: "Purge logs from main thread")
        lumberjackDelegate.purgeLogs()
        DispatchQueue.main.async {
            purgeExpectation.fulfill()
        }
        wait(for: [purgeExpectation], timeout: 1.0)
        XCTAssertTrue(lumberjackDelegate.getLogs().isEmpty)
    }
}
