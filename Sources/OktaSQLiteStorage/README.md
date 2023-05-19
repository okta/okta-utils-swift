#  Okta SQLite Storage SDK 

OktaSQLiteStorage is a lightweight wrapper on top of GRDB framework that allows easy db creation and handling migration scenarios

## Usage

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

let schema = SQLiteSchema(schema: queries, version: SchemaVersions.v1)

let sqliteStorage = try await SQLiteStorageBuilder()
                            .setWALMode(enabled: true)
                            .build(schema: schema, storagePath: dbURL)

try await sqliteStorage.initialize(storageMigrator: SQLiteMigrator())

```
