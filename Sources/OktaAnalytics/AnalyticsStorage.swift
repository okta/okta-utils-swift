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
import OktaLogger
import OktaSQLiteStorage
import GRDB

class AnalyticsStorage {

    private var lock = ReadWriteLock()
    private let logger: OktaLoggerProtocol
    private var databasPool: DatabasePool?

    init(logger: OktaLoggerProtocol) {
        self.logger = logger
    }

    func initializeDB(forSecurityApplicationGroupIdentifier groupIdentifier: String) async throws {

        guard let dbURL = dbURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
           assert(false, "cache DB URL failed")
        }
        let schema = SQLiteSchema(schema: schema, version: DBVersions.v1)
        do {
            let sqliteStorage = try await SQLiteStorageBuilder()
                                        .setWALMode(enabled: true)
                                        .build(schema: schema, storagePath: dbURL, storageMigrator: SQLiteMigrator())
            databasPool = sqliteStorage.sqlitePool
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            lock.unlock()
        }
    }

    func insertScenario(_ scenarioEvent: ScenarioEvent, completion: @escaping (ScenarioID?) -> Void) {
        do {
            lock.writeLock()
            try databasPool?.write {
                try Scenario(id: scenarioEvent.id, name: scenarioEvent.name, displayName: scenarioEvent.displayName, startTime: scenarioEvent.startTime).insert($0)
                insertScenarioProperties(db: $0, scenarioEvent.properties.compactMap { ScenarioProperty(scenarioID: scenarioEvent.id, key: $0.key, value: $0.value) })
                completion(scenarioEvent.id)
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            completion(nil)
            lock.unlock()
        }
    }

    func insertScenarioProperties(_ scenarioProperties: [ScenarioProperty]) {
        do {
            lock.writeLock()
            try databasPool?.write {
                for property in scenarioProperties {
                    try property.insert($0)
                }
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            lock.unlock()
        }
    }

    func fetchScenario(_ scenarioID: ScenarioID, completion: @escaping (Scenario?) -> Void) {
        do {
            lock.readLock()
            try databasPool?.read {
                completion(try Scenario.fetchOne($0, sql: "SELECT * FROM Scenario WHERE id = \'\(scenarioID)\'"))
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            completion(nil)
            lock.unlock()
        }
    }

    func fetchScenarioAndProperties(_ scenarioID: ScenarioID, completion: @escaping (Scenario?, [ScenarioProperty]) -> Void) {
        do {
            lock.readLock()
            try databasPool?.read {
                lock.readLock()
                completion(try Scenario.fetchOne($0, sql: "SELECT * FROM Scenario WHERE id = \'\(scenarioID)\'"), try ScenarioProperty.fetchAll($0, sql: "SELECT * FROM ScenarioProperty WHERE scenarioID = \'\(scenarioID)\'"))
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            lock.readLock()
            completion(nil, [])
        }
    }

    func fetchScenarios(by scenarioName: Name, completion: @escaping ([ScenarioEvent]) -> Void) {
        do {
            lock.readLock()
            try databasPool?.read { db in
                var scenarioEvents: [ScenarioEvent] = []
                let scenarios = try Scenario.fetchAll(db, sql: "SELECT * FROM Scenario WHERE name = \'\(scenarioName)\'")
                try scenarios.forEach {
                    let scenarioProperties = try ScenarioProperty.fetchAll(db, sql: "SELECT * FROM ScenarioProperty WHERE scenarioID = \'\($0.id)\'")
                    scenarioEvents.append(ScenarioEvent(name: $0.name, displayName: $0.displayName, properties: scenarioProperties.compactMap { Property(key: $0.key, value: $0.value) }))
                }
                completion(scenarioEvents)
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            completion([])
            lock.unlock()
        }
    }

    func fetchScenarioProperties(by scenarioID: ScenarioID, completion: @escaping ([ScenarioProperty]) -> Void) {
        do {
            lock.readLock()
            try databasPool?.read {
                completion(try ScenarioProperty.fetchAll($0, sql: "SELECT * FROM ScenarioProperty WHERE scenarioID = \'\(scenarioID)\'"))
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            completion([])
            lock.unlock()
        }
    }

    func deleteScenariosByIds(_ scenarioIDs: [ScenarioID]) {
        do {
            lock.writeLock()
            try databasPool?.write { db in
                try scenarioIDs.forEach {
                    try db.execute(sql: "DELETE FROM Scenario WHERE id = \'\($0)\'")
                }
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            lock.unlock()
        }
    }

    func deleteScenariosByNames(_ scenarioNames: [Name]) {
        do {
            lock.writeLock()
            try databasPool?.write { db in
                try scenarioNames.forEach {
                    try db.execute(sql: "DELETE FROM Scenario WHERE name = \'\($0)\'")
                }
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            lock.unlock()
        }
    }

    func deleteScenarios() {
        do {
            lock.writeLock()
            try databasPool?.write {
                try $0.execute(sql: "DELETE FROM Scenario")
                lock.unlock()
            }
        } catch {
            logger.log(error: error as NSError, file: #file, line: #line, funcName: #function)
            lock.unlock()
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
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier)
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
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
