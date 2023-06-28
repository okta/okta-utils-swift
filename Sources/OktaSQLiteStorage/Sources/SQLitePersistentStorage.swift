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

import Foundation
import GRDB

class SQLiteStorage: SQLiteStorageProtocol {
    let schema: SQLiteSchema
    let sqliteURL: URL
    let sqlitePool: DatabaseQueue

    deinit {
        print("")
    }

    init(at sqliteURL: URL,
         schema: SQLiteSchema,
         walModeEnabled: Bool,
         configuration: Configuration?,
         connectionBuilder: SQLiteConnectionBuilderProtocol = SQLiteConnectionBuilder()) throws {
        self.sqliteURL = sqliteURL
        self.schema = schema

        do {
            let fileManager = FileManager.default
            let hasDBStored = fileManager.fileExists(atPath: sqliteURL.path)
            if !hasDBStored {
                try fileManager.createDirectory(at: sqliteURL.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
            }
            let coordinator = NSFileCoordinator(filePresenter: nil)
            var coordinatorError: NSError?
            var dbPool: DatabaseQueue!
            var dbError: Error?
            let coordinationBlock: (URL) -> Void = { url in
                do {
                    dbPool = try connectionBuilder.databasePool(at: url, walModeEnabled: walModeEnabled, configuration: configuration)
                } catch {
                    dbError = error
                }
            }
            coordinator.coordinate(writingItemAt: sqliteURL, options: .forMerging, error: &coordinatorError, byAccessor: coordinationBlock)
            if let error = dbError ?? coordinatorError {
                throw SQLiteStorageError.sqliteError(error.localizedDescription)
            }
            self.sqlitePool = dbPool
        } catch {
            //logger.error(eventName: "Error on sqlitePool initialization", message: "Error: \(error)")
            throw SQLiteStorageError.sqliteError(error.localizedDescription)
        }
    }

    func initialize(storageMigrator: any SQLiteMigratable) async throws {
        do {
            let sqlUserVersion = try await sqlitePool.read { db in
                return try Int.fetchOne(db, sql: "PRAGMA user_version") ?? 0
            }

            if sqlUserVersion == self.schema.version.rawValue {
                // db schema is up to date
                return
            } else if sqlUserVersion == 0 {
                // need to build db schema and update schema version
                try await self.buildDatabaseSchema()
            } else {
                guard let currentVersion = self.schema.version.versionByRawValue(sqlUserVersion) as (any SchemaVersionType)? else {
                    throw SQLiteStorageError.migrationError(.downgradeAttempt)
                }
                // Perform migration from the last known version to the current version declared by versionable storage, one-by-one in "cascade" fashion
                //try storageMigrator.willStartIncrementalStorageMigrationSequence(startVersion: currentVersion, endVersion: schema.version)
                try self.migrateToTargetVersion(
                            fromVersion: currentVersion,
                            targetVersionRawValue: self.schema.version.rawValue,
                            migrator: storageMigrator)
            }
        } catch let error as SQLiteStorageError {
            throw error
        } catch {
            throw SQLiteStorageError.sqliteError(error.localizedDescription)
        }
    }

    func migrateToTargetVersion<T, S>(fromVersion: T, targetVersionRawValue: Int, migrator: S) throws where T: SchemaVersionType, S: SQLiteMigratable {
        guard fromVersion.rawValue <= targetVersionRawValue else {
            throw SQLiteStorageError.migrationError(.downgradeAttempt)
        }

        // swiftlint:disable:next force_cast
        try migrator.willStartIncrementalStorageMigrationSequence(startVersion: fromVersion as! S.Version, endVersion: schema.version as! S.Version)

        let allCases = T.allCases.sorted()
        guard let currentVersionIndex = allCases.firstIndex(of: fromVersion) else {
            throw SQLiteStorageError.migrationError(.badCurrentVersion)
        }
        guard let targetVersionIndex = allCases.firstIndex(where: { $0.rawValue == targetVersionRawValue }) else {
            throw SQLiteStorageError.migrationError(.badTargetVersion)
        }

        let nextVersionIndex = currentVersionIndex + 1
        guard nextVersionIndex < allCases.count else {
            // swiftlint:disable:next force_cast
            migrator.didFinishStorageIncrementalMigrationSequence(startVersion: fromVersion as! S.Version, endVersion: schema.version as! S.Version)
            return
        }

        for index in nextVersionIndex...targetVersionIndex {
            try sqlitePool.write { db in
                // swiftlint:disable:next force_cast
                try migrator.performIncrementalStorageMigration(allCases[index] as! S.Version, database: db)
                try db.execute(sql: "PRAGMA user_version=\(allCases[index].rawValue)")
            }
        }

        // swiftlint:disable:next force_cast
        migrator.didFinishStorageIncrementalMigrationSequence(startVersion: fromVersion as! S.Version, endVersion: schema.version as! S.Version)
    }

    fileprivate func buildDatabaseSchema() async throws {
        switch schema.schemaType {
        case .rawSQLSchema(let sql):
            try await sqlitePool.write { db in
                try db.execute(sql: sql)
                try db.execute(sql: "PRAGMA user_version=\(self.schema.version.rawValue)")
            }
        case .delegated(let build):
            try await sqlitePool.write { db in
                try build(db, self.schema.version.rawValue)
                try db.execute(sql: "PRAGMA user_version=\(self.schema.version.rawValue)")
            }
        }
    }
}
