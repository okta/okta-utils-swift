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
import Foundation
import Combine
import CoreData

// Extension to the Date struct, defines the subtraction operator, returning the time interval between two dates
extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        // Returns the time interval between the two dates
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}

/// This code defines a Swift class `EventScenario` which represents an event that can be tracked with analytics.
class EventScenario {

    // eventName is a constant property, initialized with the value passed to the init method
    private var scenario: ScenarioEvent

    var name: String {
        scenario.name
    }

    // properties is a dictionary of strings, initialized as an empty dictionary
    private(set) var properties: Properties = [:]
    // time is a property of type Date, initialized as the current date
    private var time = Date()

    // eventStream is a PassthroughSubject, which is private set
    private(set) var eventStream: PassthroughSubject<Property, Never>?

    // cancellable is an AnyCancellable, which is private
    private var cancellable: AnyCancellable?

    // CoreData Stack
    private let managedContext: NSManagedObjectContext

    private let scenarioStatusPropertyKey = "ScenarioStatus"
    private let durationMSPropertyKey = "DurationMS"

    var isEventExpiredOrInterrupted: Bool {
        time.distance(to: Date()) > 5.0 * 60 /* secs */
    }

    // Initializer which assigns the passed in name to the eventName property
    init(_ scenario: ScenarioEvent, managedContext: NSManagedObjectContext) {
        self.scenario = scenario
        self.managedContext = managedContext
    }

    // Method which starts the event stream, assigns the current time to the time property and sets up a sink to receive values
    func start() -> PassthroughSubject<Property, Never>? {
        eventStream = PassthroughSubject()
        let scenario = Scenario(context: managedContext)
        scenario.setValue(self.scenario.id, forKeyPath: #keyPath(Scenario.scenarioID))
        scenario.setValue(self.scenario.name, forKeyPath: #keyPath(Scenario.name))
        scenario.setValue(self.scenario.date, forKeyPath: #keyPath(Scenario.startTime))
        managedContext.saveContext()
        cancellable = eventStream?
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                self.properties?[self.durationMSPropertyKey] = "\(self.time.distance(to: Date()) * 1000)"
                self.dispose()
            } receiveValue: { [weak self] property in
                guard let `self` = self, !self.isEventExpiredOrInterrupted else {
                    self?.dispose()
                    return
                }
                self.properties?[property.key] = property.value
                let scenarioProperty = ScenarioProperty(context: self.managedContext)
                scenarioProperty.setValue(self.scenario.id, forKeyPath: #keyPath(ScenarioProperty.scenarioID))
                scenarioProperty.setValue(property.key, forKeyPath: #keyPath(ScenarioProperty.key))
                scenarioProperty.setValue(property.value, forKeyPath: #keyPath(ScenarioProperty.value))
                scenarioProperty.setValue(self.scenario.name, forKeyPath: #keyPath(ScenarioProperty.name))
                self.managedContext.saveContext()
            }
        return eventStream
    }

    // Method which calls the end method and sets the eventStream to nil
    func dispose() {
        cancellable?.cancel()
        eventStream = nil
    }

    deinit {
        cancellable?.cancel()
        cancellable = nil
    }
}

struct EventData {
    let eventName: Name
    let properties: Properties

    init(_ eventName: Name, _ properties: Properties) {
        self.eventName = eventName
        self.properties = properties
    }
}
