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

import XCTest
@testable import OktaSQLiteStorage
import GRDB

final class SQLiteStorageTests: XCTestCase {

    var dbURL: URL!

    override func setUpWithError() throws {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            dbURL = cacheURL.appendingPathComponent("sqlite.db")
        }
    }

    func testCreation() throws {

        let readFromDBExpectation = expectation(description: "Read from db expectation")
        let writeToDBExpectation = expectation(description: "Write from db expectation")

        Task {
            let schemaQueries = """
            CREATE TABLE 'Example' (
            'id' TEXT NOT NULL
            );
            """

            let schema = SQLiteSchema(schema: schemaQueries, version: SchemaVersions.v1)
            let storage = try await SQLiteStorageBuilder()
                .setWALMode(enabled: true)
                .build(schema: schema, storagePath: dbURL, storageMigrator: SQLiteMigratorMock())

            XCTAssertEqual(storage.sqliteURL, dbURL)
            try await storage.sqlitePool.write { db in
                try db.execute(literal: "INSERT INTO Example (id) VALUES (1) ")
                writeToDBExpectation.fulfill()
            }

            try await storage.sqlitePool.read { db in
                let db_version = try Int.fetchOne(db, sql: "PRAGMA user_version")
                XCTAssertEqual(db_version, SchemaVersions.v1.rawValue)
                let userData = try Int.fetchOne(db, sql: "SELECT id FROM Example WHERE id=1")
                XCTAssertEqual(userData, 1)
                readFromDBExpectation.fulfill()
            }
        }

        wait(for: [readFromDBExpectation, writeToDBExpectation], timeout: 1)
    }

    func testMigration() throws {
        try testCreation()
        let readFromDBExpectation = expectation(description: "Read from db expectation")
        let writeToDBExpectation = expectation(description: "Write from db expectation")

        Task {
            // Migrate db to version 2
            let schemaQueries = """
            CREATE TABLE 'Example' (
            'id' TEXT NOT NULL
            );
            """

            let schema = SQLiteSchema(schema: schemaQueries, version: SchemaVersions.v2)
            let storage = try await SQLiteStorageBuilder()
                .setWALMode(enabled: true)
                .build(schema: schema, storagePath: dbURL, storageMigrator: SQLiteMigratorMock())

            try await storage.sqlitePool.write { db in
                try db.execute(literal: "INSERT INTO Example2 (id) VALUES (5) ")
                writeToDBExpectation.fulfill()
            }

            try await storage.sqlitePool.read { db in
                let db_version = try Int.fetchOne(db, sql: "PRAGMA user_version")
                XCTAssertEqual(db_version, SchemaVersions.v2.rawValue)
                var userData = try Int.fetchOne(db, sql: "SELECT id FROM Example WHERE id=1")
                XCTAssertEqual(userData, 1)
                userData = try Int.fetchOne(db, sql: "SELECT id FROM Example2 WHERE id=5")
                XCTAssertEqual(userData, 5)
                readFromDBExpectation.fulfill()
            }
        }
        
        wait(for: [readFromDBExpectation, writeToDBExpectation], timeout: 1)
    }
}

enum SchemaVersions: Int, SchemaVersionType {
    case v1 = 1
    case v2 = 2
}

class SQLiteMigratorMock: SQLiteMigratable {
    typealias Version = SchemaVersions
    
    func willStartIncrementalStorageMigrationSequence(startVersion: SchemaVersions, endVersion: SchemaVersions) throws {
    }
    
    func performIncrementalStorageMigration(_ nextVersion: SchemaVersions, database: Database) throws {
        if nextVersion == .v2 {
            let queries = """
            CREATE TABLE 'Example2' (
            'id' TEXT NOT NULL
            );
            """
            try database.execute(sql: queries)
            try database.execute(sql: "PRAGMA user_version=\(nextVersion.rawValue)")
        } else {
            throw NSError(domain: "SQLiteStorageTests", code: -1)
        }
    }

    func didFinishStorageIncrementalMigrationSequence(startVersion: SchemaVersions, endVersion: SchemaVersions) {
    }
}
