#  Okta SQLite Storage SDK 

OktaSQLiteStorage is a lightweight wrapper on top of GRDB framework that allows easy db creation and handling of migration scenarios

## Getting started

### CocoaPods

This SDK is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile:

```
pod 'OktaSQLiteStorage'
```

## Usage

To start using sqlite storage you need to build and initialize `OktaSQLiteStorage` object
Steps are the following:
1. Create `SQLiteSchema` object with sql queries for your current db schema
2. Use `SQLiteStorageBuilder` builder class to build an object that conforms to `OktaSQLiteStorageProtocol` protocol. Enable WAL mode and other settings if required
3. Call `initialize` method to initialize `OktaSQLiteStorage` object and provide custom migrator object for migrating db schema. `OktaSQLiteStorage` can start migration process during this call and async call finishes whenever migration is fully completed or failed 
4. You can now start read/write access to sqlite database. Use `sqlitePool` property for interacting with database via [GRDB](https://github.com/groue/GRDB.swift) intefaces


```swift
var dbURL: URL!
if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
    dbURL = cacheURL.appendingPathComponent("sqlite.db")
}

let queries =
"""
CREATE TABLE 'Example' (
'id' TEXT NOT NULL
);
"""

// 1.
let schema = SQLiteSchema(schema: queries, version: SchemaVersions.v1)

// 2.
let sqliteStorage = try await SQLiteStorageBuilder()
                            .setWALMode(enabled: true)
                            .build(schema: schema, storagePath: dbURL)

// 3.
try await sqliteStorage.initialize(storageMigrator: SQLiteMigrator())

// 4.
let query = "INSERT INTO Example (id) VALUES (1)"
try sqliteStorage.sqlitePool.write { db in
    try db.execute(sql: query)
}
```

## Databse migration

Implement class that conforms to `SQLiteMigratable` protocol. That class will be responsible for running sql queries for each db schema version. Recommendation is to mutate schema only with additive changes. Try to avoid destrutive schema and data changes such as table deletions or transformations of historical data

```
func willStartIncrementalStorageMigrationSequence(startVersion: Version, endVersion: Version) throws {
    // migration started from startVersion to endVersion
}

func performIncrementalStorageMigration(_ nextVersion: Version, database: Database) throws {
        switch nextVersion {
        case .v1:
            // Do nothing for initial schema version
            return
        case .v2:
            let v2Queries =
            """
            CREATE TABLE 'NextExample' (
            'id' TEXT NOT NULL
            );
            """
            // Run write transaction
            try db.execute(sql: v2Queries)
        }
}

func didFinishStorageIncrementalMigrationSequence(startVersion: Version, endVersion: Version) {
    // migration successfully finished
}
```

## Database downgrade

`OktaSQLiteStorage` will detect schema version downgrade and fire `migrationError(.downgradeAttempt)` exception. `OktaSQLiteStorage` doesn't invalidate sqlite database handle(`sqlitePool` property) and keeps it active. It is up to the client how to handle that exception and whether to allow further work with database or not

```
try {
    try await sqliteStorage.initialize(storageMigrator: SQLiteMigrator())
} catch error as SQLiteStorageError {
    if case let migrationError(reason) = error,
                reason == .downgradeAttempt {
        // it is OK, allow further work with db
    }
}
} catch {
    // handle other errors
}
```
