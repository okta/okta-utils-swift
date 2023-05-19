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

/// Simplifies instantiating of SQLiteStorageBuilder object
public class SQLiteStorageBuilder {

    var walModeEnabled = false
    var configuration: GRDB.Configuration?

    /// Enables/disables WAL mode for SQLite database
    public func setWALMode(enabled: Bool) -> SQLiteStorageBuilder {
        self.walModeEnabled = enabled

        return self
    }

    /// Set extra sqlite configuration
    public func setSQLiteConfiguration(_ configuration: GRDB.Configuration) -> SQLiteStorageBuilder {
        self.configuration = configuration

        return self
    }

    public init() {}

    /// Builds object that conforms to OktaSQLiteStorageProtocol protocol
    /// - Parameters:
    ///   - schema: Your database schema
    ///   - version: Version of the database schema
    ///   - storagePath: Location of sqlite database and service files
    /// - Returns: Constructed object that conforms to OktaSQLiteStorageProtocol protocol
    public func build(schema: SQLiteSchema,
                      storagePath: URL) async throws -> SQLiteStorageProtocol {
        if schema.version.rawValue == 0 || schema.version.rawValue < 0 {
            throw SQLiteStorageError.generalError("Invalid schema version")
        }

        let sqliteStorage = try SQLiteStorage(at: storagePath,
                                              schema: schema,
                                              walModeEnabled: walModeEnabled,
                                              configuration: configuration)
        return sqliteStorage
    }
}
