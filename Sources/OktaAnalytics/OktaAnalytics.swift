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
import OktaLogger

/**
 Analytics class for holding and tracking for different tracking provider
 */
@objc
public final class OktaAnalytics: NSObject {

    private static var providers = [String: AnalyticsProviderProtocol]()
    private static var lock = ReadWriteLock()
    private static var scenarios: [EventName: EventScenario]? = [:]

    /**
     Adds provider to collection

     - Parameters:
     - provider: `AnalyticsProviderProtocol` provided by client
     */
    public static func addProvider(_ provider: AnalyticsProviderProtocol) {
        lock.writeLock()
        defer { lock.unlock() }
        providers[provider.name] = provider
    }

    /**
     Adds providers to collection

     - Parameters:
     - providers: `AnalyticsProviderProtocol`s provided by client
     */
    public static func addProviders(_ providers: [AnalyticsProviderProtocol]) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.forEach {
            Self.providers[$0.name] = $0
        }
    }

    /**
     removes providers by name

     - Parameters:
     - provider: name of the provider
     */
    public static func removeProvider(_ provider: String) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.removeValue(forKey: provider)
    }

    /**
     Remove providers from collection

     - Parameters:
     - providers: `Provider`s provided by client, if exists
     */
    public static func removeProviders(_ providers: [String]) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.forEach { Self.providers.removeValue(forKey: $0) }
    }

    /**
     Remove provider from collection

     - Parameters:
     - provider: `AnalyticsProviderProtocol` provided by client, if exists
     */
    static func removeProvider(_ provider: AnalyticsProviderProtocol) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.removeValue(forKey: provider.name)
    }

    /**
     Remove providers from collection

     - Parameters:
     - providers: `AnalyticsProviderProtocol`s provided by client, if exists
     */
    static func removeProviders(_ providers: [AnalyticsProviderProtocol]) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.forEach { Self.providers.removeValue(forKey: $0.name) }
    }

    /**
     Track event to all providers provided by client

     - Parameters:
     - eventName: `event name` provided by client
     - withProperties: `properties/metadata` associated with event
     */
    public static func trackEvent(_ eventName: String, withProperties: Properties) {
        lock.readLock()
        defer { lock.unlock() }
        providers.forEach { $1.trackEvent(eventName, withProperties: withProperties) }
    }

    /**
        Starts an event scenario with the specified name.

        - Parameters:
           - eventName: The name of the event scenario to start.
           - propertySubject: A closure that takes a `PassthroughSubject` of `Property` objects as a parameter.
        */
    public static func startScenario(_ name: ScenarioName, _ scenarioPassThrough: @escaping () -> [ScenarioState]) {
        lock.readLock()
        defer { lock.unlock() }
        let scenario = EventScenario(name) {
            Self.trackEvent($0.eventName, withProperties: $0.properties)
        }
        scenario.scenarioPassThrough(scenarioPassThrough())
        Self.scenarios?[scenario.name] = scenario
        Self.providers.forEach {
            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) already in flight", properties: nil, file: #file, line: #line, funcName: #function)
        }
    }

    /**
        add a property scenario with the values.

        - Parameters:
           - eventName: The name of the event scenario .
           - propertySubject: A closure that takes a `PassthroughSubject` of `Property` objects as a parameter.
        */
    public static func updateScenario(_ name: ScenarioName, _ scenarioPassThrough: @escaping () -> [ScenarioState]) {
        lock.readLock()
        defer { lock.unlock() }
        guard let scenario = Self.scenarios?[name] else {
            assert(false, "startScenario should be called before updateScenario")
            return
        }
        Self.providers.forEach {
            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) Updated", properties: nil, file: #file, line: #line, funcName: #function)
        }
        scenario.scenarioPassThrough(scenarioPassThrough())
    }

    /// Dispose Scenarios associated with the mprovider
    public static func disposeAllScenarios() {
        lock.readLock()
        defer { lock.unlock() }
        Self.scenarios?.removeAll()
    }

//    /**
//        Starts an event scenario with the specified name.
//
//        - Parameters:
//           - eventName: The name of the event scenario to start.
//           - propertySubject: A closure that takes a `PassthroughSubject` of `Property` objects as a parameter.
//        */
//    public static func startScenario(_ scenario: ScenarioName, _ propertySubject: (PassthroughSubject<Property, SceanrioError>?) -> Void) {
//
//        lock.readLock()
//        defer { lock.unlock() }
//
//        let scenario = EventScenario(scenario) {
//            Self.trackEvent($0.eventName, withProperties: $0.properties)
//        }
//        Self.scenarios?[scenario.name] = scenario
//        propertySubject(scenario.start())
//
//        Self.providers.forEach {
//            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) already in flight", properties: nil, file: #file, line: #line, funcName: #function)
//        }
//    }
//
//    /**
//        add a property scenario with the values.
//
//        - Parameters:
//           - eventName: The name of the event scenario .
//           - propertySubject: A closure that takes a `PassthroughSubject` of `Property` objects as a parameter.
//        */
//    public static func updateScenario(_ scenario: Scenario, _ propertySubject: (PassthroughSubject<Property, SceanrioError>?) -> Void) {
//        lock.readLock()
//        defer { lock.unlock() }
//        guard let scenario = Self.scenarios?[scenario.name] else {
//            assert(false, "startScenario should be called before updateScenario")
//            propertySubject(nil)
//            return
//        }
//        Self.providers.forEach {
//            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) Updated", properties: nil, file: #file, line: #line, funcName: #function)
//        }
//        propertySubject(scenario.eventStream)
//    }
//
//    /// Dispose Scenarios associated with the mprovider
//    public static func disposeAllScenarios() {
//        lock.readLock()
//        defer { lock.unlock() }
//        Self.scenarios?.values.forEach {
//            $0.dispose()
//        }
//        Self.scenarios?.removeAll()
//    }

    /**
     removes all providers from memory
     */
    public static func purge() {
        lock.writeLock()
        defer { lock.unlock() }
        providers.removeAll()
    }
}

public extension Dictionary {
    // Merge the contents of one dictionary into another, favoring the content of right
    static func mergeRecursive(left: inout Self, right: Self?) {
        left.merge(right ?? [:]) { current, _ in current }
    }
}

private extension OktaAnalytics {
    class ReadWriteLock: NSObject {

        func writeLock() {
            pthread_rwlock_wrlock(&self.lock)
        }

        func readLock() {
            pthread_rwlock_rdlock(&self.lock)
        }

        func unlock() {
            pthread_rwlock_unlock(&self.lock)
        }

        deinit {
            pthread_rwlock_destroy(&self.lock)
        }

        override init() {
            self.lock = pthread_rwlock_t()
            pthread_rwlock_init(&self.lock, nil)
        }

        private var lock: pthread_rwlock_t
    }
}

public enum SceanrioError: Error {
    case reason(Property)
    case never
}
