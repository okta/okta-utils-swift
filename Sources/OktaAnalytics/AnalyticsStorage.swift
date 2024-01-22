/*
* Copyright (c) 2023, Okta, Inc. and/or its affiliates. All rights reserved.
* The Okta software accompanied by this notice is provided pursuant to the Apache License, Version 2.0 (the "License.")
*
* You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0.
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*
* See the License for the specific language governing permissions and limitations under the License.
*/
import OktaLogger
import OktaSQLiteStorage
import GRDB

class AnalyticsStorage {

    private let logger: OktaLoggerProtocol
    private var databasePool: DatabasePool?

    private let queue = DispatchQueue(label: "com.AnalyticsStorage", qos: .userInitiated)

    private var semaphore = DispatchSemaphore(value: 0)

    init(logger: OktaLoggerProtocol) {
        self.logger = logger
    }

    func initializeDB(forSecurityApplicationGroupIdentifier groupIdentifier: String) {
        queue.async {
            guard let dbURL = self.dbURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
                assert(false, "cache DB URL failed")
                self.logger.error(eventName: "DB creation failed", message: "Invalid URL", properties: nil, file: #file, line: #line, funcName: #function)
                return
            }
            self.logger.info(eventName: "DBURL", message: dbURL.absoluteString, properties: nil, file: #file, line: #line, funcName: #function)
            let rawSQLSchema = SQLiteSchemaType.rawSQLSchema(sql: self.schema)
            let schema = SQLiteSchema(schemaType: rawSQLSchema, version: DBVersions.v1)
            Task(priority: .high) {
                do {
                    let sqliteStorage = try await SQLiteStorageBuilder()
                        .setWALMode(enabled: true)
                        .build(schema: schema, storagePath: dbURL)
                    try await sqliteStorage.initialize(storageMigrator: SQLiteMigrator())
                    self.databasePool = sqliteStorage.sqlitePool
                } catch {
                    self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                }
                self.semaphore.signal()
            }
            self.semaphore.wait()
        }
    }

    func insertScenario(_ scenarioEvent: ScenarioEvent, completion: @escaping (ScenarioID?) -> Void) {
        queue.async {
            do {
                try self.databasePool?.write {
                    try Scenario(id: scenarioEvent.id, name: scenarioEvent.name, displayName: scenarioEvent.displayName, startTime: scenarioEvent.startTime).insert($0)
                }

                try self.databasePool?.write {
                    self.insertScenarioProperties(db: $0, scenarioEvent.properties.compactMap { ScenarioProperty(scenarioID: scenarioEvent.id, key: $0.key, value: $0.value) })
                    completion(scenarioEvent.id)
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                completion(nil)
            }
        }
    }

    func insertScenarioProperties(_ scenarioProperties: [ScenarioProperty]) {
        queue.async {
            do {
                try self.databasePool?.write {
                    for property in scenarioProperties {
                        try property.insert($0)
                    }
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            }
        }
    }

    func fetchScenario(_ scenarioID: ScenarioID, completion: @escaping (Scenario?) -> Void) {
        queue.async {
            do {
                try self.databasePool?.read {
                    completion(try Scenario.fetchOne($0, sql: "SELECT * FROM Scenario WHERE id = \'\(scenarioID)\'"))
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                completion(nil)
            }
        }
    }

    func fetchScenarioAndProperties(_ scenarioID: ScenarioID, completion: @escaping (Scenario?, [ScenarioProperty]) -> Void) {
        queue.async {
            var scenario: Scenario?
            do {
                try self.databasePool?.read {
                    scenario = try Scenario.fetchOne($0, sql: "SELECT * FROM Scenario WHERE id = \'\(scenarioID)\'")
                }

                try self.databasePool?.read {
                    let scenarioProperties = try ScenarioProperty.fetchAll($0, sql: "SELECT * FROM ScenarioProperty WHERE scenarioID = \'\(scenarioID)\'")
                    completion(scenario, scenarioProperties)
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                completion(nil, [])
            }
        }
    }

    func fetchScenarios(by scenarioName: Name, completion: @escaping ([ScenarioEvent]) -> Void) {
        queue.async {
            var scenarios: [Scenario] = []
            do {
                try self.databasePool?.read { db in
                    scenarios = try Scenario.fetchAll(db, sql: "SELECT * FROM Scenario WHERE name = \'\(scenarioName)\'")
                }

                try self.databasePool?.read { db in
                    var scenarioEvents: [ScenarioEvent] = []
                    try scenarios.forEach {
                        let scenarioProperties = try ScenarioProperty.fetchAll(db, sql: "SELECT * FROM ScenarioProperty WHERE scenarioID = \'\($0.id)\'")
                        scenarioEvents.append(ScenarioEvent(name: $0.name, displayName: $0.displayName, properties: scenarioProperties.compactMap { Property(key: $0.key, value: $0.value) }))
                    }
                    completion(scenarioEvents)
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                completion([])
            }
        }
    }

    func fetchScenarioProperties(by scenarioID: ScenarioID, completion: @escaping ([ScenarioProperty]) -> Void) {
        queue.async {
            do {
                try self.databasePool?.read {
                    completion(try ScenarioProperty.fetchAll($0, sql: "SELECT * FROM ScenarioProperty WHERE scenarioID = \'\(scenarioID)\'"))
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                completion([])
            }
        }
    }

    func fetchScenariosAndProperties(createdBy secondsAgo: UInt, completion: @escaping ([Scenario], [ScenarioProperty]) -> Void) {
        queue.async {
            do {
                try self.databasePool?.read {
                    let scenarios = try Scenario.fetchAll($0, sql: "SELECT * FROM Scenario WHERE startTime < DATETIME('now', '-\(secondsAgo) seconds')")

                    // https://github.com/groue/GRDB.swift/issues/18#issuecomment-696574502
                    let scenariosIds = scenarios.map { $0.id }
                    let request: SQLRequest<ScenarioProperty> = "SELECT * FROM ScenarioProperty WHERE ScenarioID IN \(scenariosIds)"
                    let scenarioProperties = try request.fetchAll($0)
                    completion(scenarios, scenarioProperties)
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                completion([], [])
            }
        }
    }

    func deleteScenariosByIds(_ scenarioIDs: [ScenarioID]) {
        queue.async {
            do {
                try self.databasePool?.write { db in
                    try scenarioIDs.forEach {
                        try db.execute(sql: "DELETE FROM Scenario WHERE id = \'\($0)\'")
                    }
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            }
        }
    }

    func deleteScenariosByNames(_ scenarioNames: [Name]) {
        queue.async {
            do {
                try self.databasePool?.write { db in
                    try scenarioNames.forEach {
                        try db.execute(sql: "DELETE FROM Scenario WHERE name = \'\($0)\'")
                    }
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            }
        }
    }

    func deleteScenarios() {
        queue.async {
            do {
                try self.databasePool?.write {
                    try $0.execute(sql: "DELETE FROM Scenario")
                }
            } catch {
                self.logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            }
        }
    }
}

private extension AnalyticsStorage {

    func insertScenarioProperties(db: Database, _ scenarioProperties: [ScenarioProperty]) {
        do {
            for property in scenarioProperties {
                do {
                    try property.insert(db)
                } catch {
                    logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
                }
            }
        }
    }

    enum DBVersions: Int, SchemaVersionType {
        case v1 = 1
    }

    class SQLiteMigrator: SQLiteMigratable {
        typealias Version = DBVersions
        func willStartIncrementalStorageMigrationSequence(startVersion: DBVersions, endVersion: DBVersions) throws { }
        func performIncrementalStorageMigration(_ nextVersion: DBVersions, database: Database) throws { }
        func didFinishStorageIncrementalMigrationSequence(startVersion: DBVersions, endVersion: DBVersions) { }
    }

    func dbURL(forSecurityApplicationGroupIdentifier groupIdentifier: String) -> URL? {
        guard let cacheURL = !groupIdentifier.isEmpty ? FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) : FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            assert(false, "cache DB URL failed")
            return nil
        }
        return cacheURL.appendingPathComponent("OktaAnalytics.db")
    }

    var analyticsDB: String { "OktaAnalytics.db" }

    var schema: String {
    """
    CREATE TABLE if not exists 'Scenario' (
    'id' TEXT PRIMARY KEY,
    'name' TEXT NOT NULL,
    'displayName' TEXT,
    'startTime' DATE NOT NULL
    );
    CREATE TABLE if not exists 'ScenarioProperty' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'scenarioID' TEXT NOT NULL,
    'value' TEXT NOT NULL,
    'key' TEXT NOT NULL,
    CONSTRAINT fk_scenarioID
    FOREIGN KEY (scenarioID)
    REFERENCES Scenario(id)
    ON DELETE CASCADE);
    """
    }
}

struct Scenario: Codable, FetchableRecord, PersistableRecord {
    let id: String
    var name: String
    var displayName: String
    var startTime: Date
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
