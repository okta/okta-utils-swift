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
import CoreData

/**
 Analytics class for holding and tracking for different tracking provider
 */
@objc
public final class OktaAnalytics: NSObject {

    private static var providers = [String: AnalyticsProviderProtocol]()
    private static var lock = ReadWriteLock()
    private static var scenarios: [ScenarioID: EventScenario]? = [:]

    static var coreDataStack: CoreDataStack = {
        CoreDataStack(modelName: "OktaAnalytics")
    }()

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
    public static func startScenario(_ scenarioName: Name, _ propertySubject: (PassthroughSubject<Property, Never>?) -> Void) -> ScenarioID {

        lock.readLock()
        defer { lock.unlock() }

        var scenario = ScenarioEvent(name: scenarioName)
        let eventScenario = EventScenario(scenario, managedContext: coreDataStack.managedContext)
        Self.scenarios?[scenario.id] = eventScenario
        propertySubject(eventScenario.start())

        Self.providers.forEach {
            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) already in flight", properties: nil, file: #file, line: #line, funcName: #function)
        }
        return scenario.id
    }

    /**
        update a property scenario with the values.

        - Parameters:
           - scenarioID: unique sceario ID returned from `startScenario(_ , _)` .
           - propertySubject: A closure that takes a `PassthroughSubject` of `Property` objects as a parameter.
        */
    public static func updateScenario(_ scenarioID: ScenarioID, _ propertySubject: (PassthroughSubject<Property, Never>?) -> Void) {
        lock.readLock()
        defer { lock.unlock() }
        guard let scenario = Self.scenarios?[scenarioID] else {
            assert(false, "startScenario should be called before updateScenario")
            propertySubject(nil)
            return
        }
        Self.providers.forEach {
            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) Updated", properties: nil, file: #file, line: #line, funcName: #function)
        }
        propertySubject(scenario.eventStream)
    }

    /**
        end sceanrio with ID. send properties to provider and clears local storage.

        - Parameters:
           - scenarioID: unique sceario ID returned from `startScenario(_ , _)` .
           - eventDisplayName: event name to display on provider dashboard.
        */
    public static func endScenario(_ scenarioID: ScenarioID, eventDisplayName: Name) {
        lock.readLock()
        defer { lock.unlock() }

        guard let scenario = Self.scenarios?[scenarioID] else {
            assert(false, "No Scenario to end")
            return
        }

        scenario.eventStream?.send(completion: .finished)

        Self.trackEvent(eventDisplayName, withProperties: scenario.properties)
        Self.scenarios?.removeValue(forKey: scenarioID)

        let scenarioFetchRequest = NSFetchRequest<Scenario>(entityName: "Scenario")
        scenarioFetchRequest.predicate = NSPredicate(format: "scenarioID CONTAINS %@", scenarioID)
        do {
            let scenarios = try Self.coreDataStack.managedContext.fetch(scenarioFetchRequest)
            for scenario in scenarios {
                Self.coreDataStack.managedContext.delete(scenario)
            }
        } catch {
            assert(false, "Failed to fetch scenarios")
        }
        Self.coreDataStack.managedContext.saveContext()

        let scenarioPropertiesFetchRequest = NSFetchRequest<ScenarioProperty>(entityName: "ScenarioProperty")
        scenarioPropertiesFetchRequest.predicate = NSPredicate(format: "scenarioID CONTAINS %@", scenarioID)
        do {
            let scenarioProperties = try Self.coreDataStack.managedContext.fetch(scenarioPropertiesFetchRequest)
            for scenarioProperty in scenarioProperties {
                Self.coreDataStack.managedContext.delete(scenarioProperty)
            }
        } catch {
            assert(false, "Failed to fetch scenario properties")
        }
        Self.coreDataStack.managedContext.saveContext()
    }

    /**
        end sceanrio with scenario name. send all properties to provider and clears local storage.

        - Parameters:
           - name: scenario name
        */
    public static func endScenario(_ name: Name) {
        lock.readLock()
        defer { lock.unlock() }

        func fetchProperties(_ scenarioName: Name) -> [String: String] {
            var properties = [String: String]()
            let scenarioPropertiesFetchRequest = NSFetchRequest<ScenarioProperty>(entityName: "ScenarioProperty")
            scenarioPropertiesFetchRequest.predicate = NSPredicate(format: "name CONTAINS %@", name)
            do {
                let scenarioProperties = try Self.coreDataStack.managedContext.fetch(scenarioPropertiesFetchRequest)
                for scenarioProperty in scenarioProperties {
                    if let key = scenarioProperty.key {
                        properties[key] = scenarioProperty.value
                    }
                    Self.coreDataStack.managedContext.delete(scenarioProperty)
                }
            } catch {
                assert(false, "Failed to fetch scenario properties")
            }
            Self.coreDataStack.managedContext.saveContext()
            return properties
        }

        let scenarioFetchRequest = NSFetchRequest<Scenario>(entityName: "Scenario")
        scenarioFetchRequest.predicate = NSPredicate(format: "name CONTAINS %@", name)
        do {
            let scenarios = try Self.coreDataStack.managedContext.fetch(scenarioFetchRequest)
            for scenario in scenarios {
                if let displayName = scenario.displayName {
                    Self.trackEvent(displayName, withProperties: fetchProperties(name))
                }
                Self.coreDataStack.managedContext.delete(scenario)
            }
        } catch {
            assert(false, "Failed to fetch scenarios")
        }
        Self.coreDataStack.managedContext.saveContext()
    }

    /**
        end sceanrio with scenario name. clears local storage.

        - Parameters:
           - name: scenario name
        */
    public static func disposeScenario(_ name: Name) {
        lock.readLock()
        defer { lock.unlock() }

        let scenarioFetchRequest = NSFetchRequest<Scenario>(entityName: "Scenario")
        scenarioFetchRequest.predicate = NSPredicate(format: "name CONTAINS %@", name)
        do {
            let scenarios = try Self.coreDataStack.managedContext.fetch(scenarioFetchRequest)
            for scenario in scenarios {
                Self.coreDataStack.managedContext.delete(scenario)
            }
        } catch {
            assert(false, "Failed to fetch scenarios")
        }
        Self.coreDataStack.managedContext.saveContext()

        let scenarioPropertiesFetchRequest = NSFetchRequest<ScenarioProperty>(entityName: "ScenarioProperty")
        scenarioPropertiesFetchRequest.predicate = NSPredicate(format: "name CONTAINS %@", name)
        do {
            let scenarioProperties = try Self.coreDataStack.managedContext.fetch(scenarioPropertiesFetchRequest)
            for scenarioProperty in scenarioProperties {
                Self.coreDataStack.managedContext.delete(scenarioProperty)
            }
        } catch {
            assert(false, "Failed to fetch scenario properties")
        }
        Self.coreDataStack.managedContext.saveContext()
    }

    /// Dispose Scenarios from local storage
    public static func disposeAllScenarios() {
        lock.readLock()
        defer { lock.unlock() }
        Self.scenarios?.values.forEach {
            $0.dispose()
        }
        Self.scenarios?.removeAll()

        do {
            try Self.coreDataStack.managedContext.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "Scenario")))
            try Self.coreDataStack.managedContext.execute(NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "ScenarioProperty")))
        } catch {
            assert(false, "Failed to fetch scenarios")
        }
    }

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
