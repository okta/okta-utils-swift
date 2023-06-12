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
@testable import GRDB

final class SQLiteConnectionBuilderTests: XCTestCase {

    var dbURL: URL!
    var cacheDirectory: URL!

    override func setUpWithError() throws {
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            cacheDirectory = cacheURL
            dbURL = cacheURL.appendingPathComponent("sqlite.db")
            try? FileManager.default.removeItem(at: dbURL)
        }
    }

    func testDatabasePool() throws {
        let connectionBuilder = SQLiteConnectionBuilder()
        var configuration = Configuration()
        configuration.maximumReaderCount = 10
        let dbPool = try connectionBuilder.databasePool(at: dbURL, walModeEnabled: true, configuration: configuration)
        let expectedWALFileLocation = cacheDirectory.appendingPathComponent("sqlite.db-wal").path
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedWALFileLocation))
        XCTAssertEqual(dbPool.configuration.maximumReaderCount, configuration.maximumReaderCount)
    }
}
