/*
 * Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

class OktaLoggerFirebaseLoggerTests: XCTestCase {

  
    ///  Verify that the userInfo dict is created as expected
    ///  defaultProperties and logged properties should be merged into the userInfo dict in correct priority
    func testUserInfoMerge() {
        let eventName = UUID().uuidString
        let message = UUID().uuidString
        let pushToken = UUID().uuidString
        let properties = [
            "pushToken": pushToken,
            "override" : "SUCCESS"
        ]
        let appInstanceId = UUID().uuidString
        let file = UUID().uuidString
        let defaultProperties = [
            "appInstanceId": appInstanceId,
            "override": "FAIL",
            "file": "<REDACTED>"
        ]
        let line = NSNumber(integerLiteral: 33)
        let funcName = UUID().uuidString
        let userInfo = OktaLoggerFirebaseCrashlyticsLogger.createUserInfoDict(level: .warning,
                                                                              eventName: eventName,
                                                                              message: message,
                                                                              properties: properties,
                                                                              defaultProperties: defaultProperties,
                                                                              file: file,
                                                                              line: line,
                                                                              funcName: funcName)
        
        XCTAssertEqual(userInfo["eventName"] as? String, eventName)
        XCTAssertEqual(userInfo["message"] as? String, message)
        XCTAssertEqual(userInfo["pushToken"] as? String, pushToken)
        XCTAssertEqual(userInfo["appInstanceId"] as? String, appInstanceId)
        XCTAssertEqual(userInfo["line"] as? NSNumber, line)
        XCTAssertEqual(userInfo["function"] as? String, funcName)
        XCTAssertEqual(userInfo["override"] as? String, "SUCCESS")
        XCTAssertEqual(userInfo["file"] as? String, "<REDACTED>")

    }

}
