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

@testable import OktaAnalytics
import CoreData
import Combine

class AnalyticsTests: XCTestCase {
    let coreDataStack = OktaAnalytics.coreDataStack

    func test_Sceanrio() {
        let scenarioName = "Test"
        let scenarioID = OktaAnalytics.startScenario(scenarioName) { $0?.send(Property(key: "Start", value: "1")) }
        XCTAssertTrue(checkIfScenarioExistsInDB(scenarioID))
        XCTAssertEqual(scenarioPropertiesCount(scenarioID), 1)

        OktaAnalytics.updateScenario(scenarioName) { $0?.send(Property(key: "Start1", value: "2")) }
        XCTAssertTrue(checkIfScenarioExistsInDB(scenarioID))
        XCTAssertEqual(scenarioPropertiesCount(scenarioID), 2)

        OktaAnalytics.updateScenario(scenarioName) { $0?.send(Property(key: "Start2", value: "3")) }
        XCTAssertTrue(checkIfScenarioExistsInDB(scenarioID))
        XCTAssertEqual(scenarioPropertiesCount(scenarioID), 3)

        OktaAnalytics.updateScenario(scenarioName) { $0?.send(Property(key: "Start3", value: "4")) }
        XCTAssertTrue(checkIfScenarioExistsInDB(scenarioID))
        XCTAssertEqual(scenarioPropertiesCount(scenarioID), 4)

        OktaAnalytics.endScenario(scenarioID, eventDisplayName: "send")
        XCTAssertFalse(checkIfScenarioExistsInDB(scenarioID))
        XCTAssertEqual(scenarioPropertiesCount(scenarioID), 0)
    }

    override class func tearDown() {
        OktaAnalytics.disposeAllScenarios()
    }

    func checkIfScenarioExistsInDB(_ scenarioID: ScenarioID) -> Bool {
        let scenarioFetchRequest = NSFetchRequest<Scenario>(entityName: "Scenario")
        scenarioFetchRequest.predicate = NSPredicate(format: "scenarioID CONTAINS %@", scenarioID)
        do {
            return try !coreDataStack.managedContext.fetch(scenarioFetchRequest).isEmpty
        } catch {
            assert(false, "Failed to fetch scenarios")
        }
        return false
    }

    func scenarioPropertiesCount(_ scenarioID: ScenarioID) -> Int {
        let scenarioFetchRequest = NSFetchRequest<Scenario>(entityName: "ScenarioProperty")
        scenarioFetchRequest.predicate = NSPredicate(format: "scenarioID CONTAINS %@", scenarioID)
        do {
            return try coreDataStack.managedContext.fetch(scenarioFetchRequest).count
        } catch {
            assert(false, "Failed to fetch scenarios")
        }
        return 0
    }
}
