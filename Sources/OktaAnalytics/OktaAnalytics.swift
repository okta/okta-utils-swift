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
import OktaSQLiteStorage
import GRDB

/**
 Analytics class for holding and tracking for different tracking provider
 */

@objc
public final class OktaAnalytics: NSObject {

    private static var providers = [String: AnalyticsProviderProtocol]()
    private static var lock = ReadWriteLock()

    private static var storage: AnalyticsStorage = {
        let logger = OktaLogger()
        logger.addDestination(
            OktaLoggerConsoleLogger(
                identifier: "com.okta.Analytics.storage",
                level: OktaLoggerLogLevel.debug,
                defaultProperties: nil
            )
        )
        return AnalyticsStorage(logger: logger)
    }()

    /**
     Adds provider to collection

     - Parameters:
        - securityAppGroupIdentifier: shared group Identifier to be data shared between app, extensions, app and widgets.
     */
    public static func initializeStorageWith(securityAppGroupIdentifier: String) {
        storage.initializeDB(forSecurityApplicationGroupIdentifier: securityAppGroupIdentifier)
    }

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
     removes all providers from memory
     */
    public static func disposeProviders() {
        lock.writeLock()
        defer { lock.unlock() }
        providers.removeAll()
    }

    /**
     removes all providers, scenarios from memory
     */
    public static func disposeAll() {
        lock.writeLock()
        defer { lock.unlock() }
        disposeProviders()
        disposeAllScenarios()
    }
}

// Extensions
public extension Dictionary {
    // Merge the contents of one dictionary into another, favoring the content of right
    static func mergeRecursive(left: inout Self, right: Self?) {
        left.merge(right ?? [:]) { current, _ in current }
    }
}

// Extensions
extension OktaAnalytics {
    /**
        Starts an event scenario with the specified name.

        - Parameters:
           - eventName: The name of the event scenario to start.
        */
    public static func startScenario(_ scenarioEvent: ScenarioEvent, _ completion: @escaping (ScenarioID?) -> Void) {
        completion(scenarioEvent.id)
        storage.insertScenario(scenarioEvent) { scenarioID in
           guard let scenarioID = scenarioID else {
               completion(nil)
               Self.providers.forEach {
                   $1.logger?.log(level: .debug, eventName: scenarioEvent.name, message: "Failed to create \(scenarioEvent.name)", properties: nil, file: #file, line: #line, funcName: #function)
               }
               return
            }
        }
        Self.providers.forEach {
            $1.logger?.log(level: .debug, eventName: scenarioEvent.name, message: "\(scenarioEvent.name) created with \(scenarioEvent.id)", properties: nil, file: #file, line: #line, funcName: #function)
        }
    }

    /**
        update a property scenario with the values.

        - Parameters:
           - scenarioID: unique sceario ID returned from `startScenario(_ , _)` .
           - properties: properties associated to scenario .
        */
    public static func updateScenario(_ scenarioID: ScenarioID, _ properties: [Property]) {
        storage.insertScenarioProperties(properties.compactMap { ScenarioProperty(scenarioID: scenarioID, key: $0.key, value: $0.value) })
    }

    /**
        Returns `ScenarioEvent` object for a given scenario ID. if exists.

        - Parameters:
           - scenarioID: unique sceario ID returned from `startScenario(_ , _)` .
        */
    public static func getScenarioEventByID(_ scenarioID: ScenarioID, _ completion: @escaping (ScenarioEvent?) -> Void) {
        storage.fetchScenarioAndProperties(scenarioID) { scenario, scenarioProperties in
            guard let scenario = scenario else {
                completion(nil)
                Self.providers.forEach {
                    $1.logger?.log(level: .debug, eventName: scenarioID, message: "Failed to fetch scenario event by \(scenarioID)", properties: nil, file: #file, line: #line, funcName: #function)
                }
                return
            }
            completion(ScenarioEvent(name: scenario.name, displayName: scenario.displayName, properties: scenarioProperties.compactMap { Property(key: $0.key, value: $0.value) }))
        }
    }

    /**
        Returns scenario Ids in completion for a given scenario name.

        - Parameters:
           - scenarioName: Name assosiated in `ScenarioEvent`  .
        */
    public static func getOngoingScenarioIds(_ scenarioName: Name, _ completion: @escaping ([ScenarioID]) -> Void) {
        storage.fetchScenarios(by: scenarioName) {
            completion($0.compactMap { $0.id })
        }
    }

    /**
        end sceanrio with ID. send properties to provider and clears local storage.

        - Parameters:
           - scenarioID: unique sceario ID returned from `startScenario(_ , _)` .
           - eventDisplayName: event name to display on provider dashboard.
        */
    public static func endScenario(_ scenarioID: ScenarioID, eventDisplayName: Name) {
        storage.fetchScenarioAndProperties(scenarioID) { scenario, properties in
            guard let scenario = scenario else {
                Self.providers.forEach {
                    $1.logger?.log(
                        level: .debug,
                        eventName: scenarioID,
                        message: "Failed to end scenario \(scenarioID) because scenario won't exists",
                        properties: nil,
                        file: #file,
                        line: #line,
                        funcName: #function
                    )
                }
                return
            }
            var propertiesDict: Dictionary = .init(properties.lazy.map { ($0.key, $0.value) }, uniquingKeysWith: { (_, last) in last })
            propertiesDict["DurationMS"] = "\(scenario.startTime.distance(to: Date()) * 1000)"
            trackEvent(eventDisplayName, withProperties: propertiesDict)
            storage.deleteScenariosByIds([scenarioID])
        }
    }

    /**
        end sceanrio with scenario name. send all properties to provider and clears local storage.

        - Parameters:
           - name: scenario name
        */
    public static func endScenario(_ name: Name) {
        storage.fetchScenarios(by: name) {
            $0.forEach { scenario in
                var properties: Dictionary = .init(scenario.properties.lazy.map { ($0.key, $0.value) }, uniquingKeysWith: { (_, last) in last })
                    properties["DurationMS"] = "\(scenario.startTime.distance(to: Date()) * 1000)"
                    trackEvent(scenario.displayName, withProperties: properties)
            }
            disposeScenario(name)
        }
    }

    /**
        end sceanrio with scenario name. clears local storage.
        Note: events wont be reported to providers
        - Parameters:
           - name: scenario name
        */
    public static func disposeScenario(_ name: Name) {
        storage.deleteScenariosByNames([name])
    }

    /// Dispose Scenarios from local storage
    /// Note: events wont be reported to providers
    public static func disposeAllScenarios() {
        storage.deleteScenarios()
    }
}
