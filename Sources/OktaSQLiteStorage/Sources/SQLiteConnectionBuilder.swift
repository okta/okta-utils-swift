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

protocol SQLiteConnectionBuilderProtocol {
    func databasePool(at databaseURL: URL, walModeEnabled: Bool, configuration: Configuration?) throws -> DatabasePool
}

class SQLiteConnectionBuilder: SQLiteConnectionBuilderProtocol {
    func databasePool(at databaseURL: URL,
                      walModeEnabled: Bool,
                      configuration: Configuration?) throws -> DatabasePool {
        try databasePool(at: databaseURL, sqliteFileEncryptionKey: nil, walModeEnabled: walModeEnabled, configuration: configuration)
    }

    private func databasePool(at databaseURL: URL,
                              sqliteFileEncryptionKey: Data?,
                              walModeEnabled: Bool,
                              configuration: Configuration?) throws -> DatabasePool {
        var grdbConfiguration: Configuration
        if let configuration = configuration {
            grdbConfiguration = configuration
        } else {
            grdbConfiguration = Configuration()
            grdbConfiguration.busyMode = .timeout(1) // retry in 1 second if write failed with SQLITE_BUSY error(other process locked db/table)
        }

        grdbConfiguration.prepareDatabase { db in
            // Activate the persistent WAL mode so that
            // readonly processes can access the database.
            //
            // See https://www.sqlite.org/walformat.html#operations_that_require_locks_and_which_locks_those_operations_use
            // and https://www.sqlite.org/c3ref/c_fcntl_begin_atomic_write.html#sqlitefcntlpersistwal
            if walModeEnabled {
                var flag: CInt = 1
                let code = withUnsafeMutablePointer(to: &flag) { flagP in
                    sqlite3_file_control(db.sqliteConnection, nil, SQLITE_FCNTL_PERSIST_WAL, flagP)
                }
                guard code == SQLITE_OK else {
                    throw DatabaseError(resultCode: ResultCode(rawValue: code))
                }
            }

            if let fileEncryptionKey = sqliteFileEncryptionKey {
                #if GRDBCIPHER
                try db.usePassphrase(fileEncryptionKey)
                #else
                assertionFailure("fileEncryptionKey is specified for SQLite, while SQLCipher is not integrated. Please, consider to link podspec ending with 'SQLCipher' suffix")
                #endif
            }
        }

        let dbPool = try DatabasePool(path: databaseURL.path, configuration: grdbConfiguration)
        return dbPool
    }
}
