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
    private let scenario: Scenario

    var name: String {
        scenario.name
    }

    // properties is a dictionary of strings, initialized as an empty dictionary
    private var properties: Properties = [:]
    // time is a property of type Date, initialized as the current date
    private var time = Date()

    // eventStream is a PassthroughSubject, which is private set
    private(set) var eventStream: PassthroughSubject<Property, SceanrioError>?

    // cancellable is an AnyCancellable, which is private
    private var cancellable: AnyCancellable?

    // User defaults object to store properties
    private let userDefaults: UserDefaults

    private var eventDateKey: String {
        "EventDate" + scenario.name
    }

    private let scenarioCompletion: (EventData) -> Void?

    private let scenarioStatusPropertyKey = "ScenarioStatus"
    private let durationMSPropertyKey = "DurationMS"

    var isEventExpiredOrInterrupted: Bool {
        time.distance(to: Date()) > 5.0 * 60 /* secs */
    }

    // Initializer which assigns the passed in name to the eventName property
    init(_ scenario: Scenario, userDefaults: UserDefaults = UserDefaults.standard, _ scenarioCompletion: @escaping (EventData) -> Void) {
        self.scenario = scenario
        self.userDefaults = userDefaults
        self.scenarioCompletion = scenarioCompletion
    }

    // Method which starts the event stream, assigns the current time to the time property and sets up a sink to receive values
    func start() -> PassthroughSubject<Property, SceanrioError>? {

        // check if previous event exists in memory without ended
        if var properties = userDefaults.value(forKey: scenario.name) as? Properties,
           let eventDate = userDefaults.value(forKey: eventDateKey) as? Date {
            var eventStatus = EventScenario.Status.expired
            if eventDate.distance(to: Date()) < 5 * 60 /* secs */ {
                eventStatus = .interrupted
            }

            properties?[scenarioStatusPropertyKey] = eventStatus.rawValue
            properties?[durationMSPropertyKey] = "\(eventDate.distance(to: Date()) * 1000)"
            scenarioCompletion(EventData(scenario.name + scenario.failureSuffix, properties))
            userDefaults.removeObject(forKey: scenario.name)
            userDefaults.removeObject(forKey: eventDateKey)
        }

        eventStream = PassthroughSubject()
        time = Date()

        // Save Event date to use next time for pending events that was not sent to provider
        userDefaults.set(time, forKey: eventDateKey)

        cancellable = eventStream?
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                self.properties?[self.durationMSPropertyKey] = "\(self.time.distance(to: Date()) * 1000)"
                switch completion {
                case .finished:
//                    self.properties?[self.scenarioStatusPropertyKey] = EventScenario.Status.completed.rawValue
                    self.scenarioCompletion(EventData(self.scenario.name + self.scenario.successSuffix, self.properties))
                case .failure(let error):
                    if case let .reason(property) = error {
                        self.properties?[property.key] = property.value
                    }
//                    self.properties?[self.scenarioStatusPropertyKey] = EventScenario.Status.completed.rawValue
                    self.scenarioCompletion(EventData(self.scenario.name + self.scenario.failureSuffix, self.properties))
                }

                self.userDefaults.removeObject(forKey: self.scenario.name)
                self.dispose()
            } receiveValue: { [weak self] property in
                guard let `self` = self, !self.isEventExpiredOrInterrupted else {
                    self?.dispose()
                    return
                }
                self.properties?[property.key] = property.value
                self.userDefaults.set(self.properties, forKey: self.scenario.name)
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

extension EventScenario {
    enum Status: String {
//        case completed
//        case failed
        case expired
        case interrupted
    }
}

struct EventData {
    let eventName: EventName
    let properties: Properties

    init(_ eventName: EventName, _ properties: Properties) {
        self.eventName = eventName
        self.properties = properties
    }
}
