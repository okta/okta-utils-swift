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
import OktaSQLiteStorage
import GRDB

/**
 Analytics class for holding and tracking for different tracking provider
 */

@objc
public final class OktaAnalytics: NSObject {

    private static var providers = [String: AnalyticsProviderProtocol]()
    private static var lock = ReadWriteLock()
    private static var scenarios: [ScenarioID: Scenario]? = [:]

    private static var databasePool: DatabasePool?

    /**
     Adds provider to collection

     - Parameters:
     - provider: `AnalyticsProviderProtocol` provided by client
     */
    public static func addProvider(_ provider: AnalyticsProviderProtocol) {
        lock.writeLock()
        defer { lock.unlock() }
        Task(priority: .high) { try await Self.checkAndInitializeDB() }
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
        Task(priority: .high) { try await Self.checkAndInitializeDB() }
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
    public static func startScenario(_ scenarioName: Name, _ properties: [Property]) -> ScenarioID {
        lock.readLock()
        Task(priority: .high) { try await checkAndInitializeDB() }
        defer { lock.unlock() }
        let databasePool = Self.databasePool
        let scenario = Scenario(name: scenarioName, displayName: "", startTime: Date())
        Self.scenarios?[scenario.id] = scenario

        Self.providers.forEach {
            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) already in flight", properties: nil, file: #file, line: #line, funcName: #function)
        }

        do {
            try databasePool?.write {
                try scenario.insert($0)
            }
        } catch {
            print(error)
        }

        return scenario.id
    }

    /**
        update a property scenario with the values.

        - Parameters:
           - scenarioID: unique sceario ID returned from `startScenario(_ , _)` .
           - propertySubject: A closure that takes a `PassthroughSubject` of `Property` objects as a parameter.
        */
    public static func updateScenario(_ scenarioID: ScenarioID, _ properties: [Property]) {
        lock.readLock()
        defer { lock.unlock() }
        guard let scenario = Self.scenarios?[scenarioID] else {
            assert(false, "startScenario should be called before updateScenario")
            return
        }
        Self.providers.forEach {
            $1.logger?.log(level: .debug, eventName: scenario.name, message: "\($0) Scenario \(scenario.name) Updated", properties: nil, file: #file, line: #line, funcName: #function)
        }

        do {
            try databasePool?.write {
                for property in properties {
                    try ScenarioProperty(scenarioID: scenarioID, key: property.key, value: property.value).insert($0)
                }
            }
        } catch {
            print(error)
        }
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
    }

    /**
        end sceanrio with scenario name. send all properties to provider and clears local storage.

        - Parameters:
           - name: scenario name
        */
    public static func endScenario(_ name: Name) {
        lock.readLock()
        defer { lock.unlock() }
    }

    /**
        end sceanrio with scenario name. clears local storage.

        - Parameters:
           - name: scenario name
        */
    public static func disposeScenario(_ name: Name) {
        lock.readLock()
        defer { lock.unlock() }
    }

    /// Dispose Scenarios from local storage
    public static func disposeAllScenarios() {
        lock.readLock()
        defer { lock.unlock() }
        Self.scenarios?.removeAll()
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

    static func createTables(databasePool: DatabasePool) throws {
        try Self.databasePool?.write { db in
            try db.create(table: "scenario", options: .ifNotExists) { t in
                t.column("scenarioID", .text)
                t.column("name", .text)
                t.column("displayName", .text)
                t.column("startTime", .date)
            }

            try db.create(table: "scenarioProperty", options: .ifNotExists) { t in
                t.autoIncrementedPrimaryKey("id")
                t.foreignKey(["scenarioID"], references: "scenario", columns: ["ScenarioID"])
                t.column("value", .text)
                t.column("key", .text)
            }
        }
    }

    static func checkAndInitializeDB() async throws {
        if databasePool != nil { return }
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
           fatalError()
        }
        let dbURL = cacheURL.appendingPathComponent("OktaAnalytics.db")
        let queries = ""
        print(dbURL)
        let schema = SQLiteSchema(schema: queries, version: DBVersions.v1)

        let sqliteStorage = try await SQLiteStorageBuilder()
                                    .setWALMode(enabled: true)
                                    .build(schema: schema, storagePath: dbURL, storageMigrator: SQLiteMigrator())
        try createTables(databasePool: sqliteStorage.sqlitePool)
        databasePool = sqliteStorage.sqlitePool
    }
}

extension OktaAnalytics {
    enum DBVersions: Int, SchemaVersionType {
        case v1 = 1
        case v2 = 2
    }

    class SQLiteMigrator: SQLiteMigratable {
        typealias Version = DBVersions
        func willStartIncrementalStorageMigrationSequence(startVersion: DBVersions, endVersion: DBVersions) throws { }
        func performIncrementalStorageMigration(_ nextVersion: DBVersions, database: Database) throws { }
        func didFinishStorageIncrementalMigrationSequence(startVersion: DBVersions, endVersion: DBVersions) { }
    }

}

struct Scenario: Codable, FetchableRecord, PersistableRecord {
    let id: String = UUID().uuidString
    var name: String
    var displayName: String
    var startTime: Date
    var properties: [ScenarioProperty]?
}

struct ScenarioProperty: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    var scenarioID: String
    var key: String
    var value: String

    init(id: Int64, scenarioID: String, key: String, value: String) {
        self.id = id
        self.scenarioID = scenarioID
        self.key = key
        self.value = value
    }

    init(scenarioID: String, key: String, value: String) {
        self.scenarioID = scenarioID
        self.key = key
        self.value = value
    }
}
