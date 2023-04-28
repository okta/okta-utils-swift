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
import UIKit
import Firebase
import OktaLogger
import OktaAnalytics
import AppCenterAnalytics
import OktaSQLiteStorage
import GRDB

enum DBVersions: Int, SchemaVersionType {
    case v1 = 1
    case v2 = 2
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let appCenterAnalyticsProvider: AnalyticsProviderProtocol = {
        let logger = OktaLogger()
        logger.addDestination(
            OktaLoggerConsoleLogger(
                identifier: "com.okta.loggerDemo.console",
                level: OktaLoggerLogLevel.debug,
                defaultProperties: nil
            )
        )
        let appCenterAnalyticsProvider = AppCenterAnalyticsProvider(name: "AppCenter", logger: logger, appCenter: AppCenterAnalytics.Analytics.self)
        appCenterAnalyticsProvider.start(withAppSecret: "App Secret", services: [AppCenterAnalytics.Analytics.self])
        
        return appCenterAnalyticsProvider
    }()

    var timer: Timer?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        OktaAnalytics.addProvider(appCenterAnalyticsProvider)
        OktaAnalytics.trackEvent("applicationDidFinishLaunchingWithOptions", withProperties: nil)
        
        var userCacheURL: URL!
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            userCacheURL = cacheURL.appendingPathComponent("sqlite.db")
        }
        
        let queries = """
        CREATE TABLE 'Example' (
        'id' TEXT NOT NULL
        );
        """
        let schema = SQLiteSchema(schema: queries, version: DBVersions.v2)

        
        Task {
            do {
                let storage = try await SQLiteStorageBuilder()
                                            .setWALMode(enabled: true)
                                            .build(schema: schema, storagePath: userCacheURL, storageMigrator: SQLiteMigrator())
                
            } catch {
                print(error.localizedDescription)
            }
        }

        return true
    }
}

class SQLiteMigrator: SQLiteMigratable {
    typealias Version = DBVersions
    
    func willStartIncrementalStorageMigrationSequence(startVersion: DBVersions, endVersion: DBVersions) throws {
        
    }
    
    func performIncrementalStorageMigration(_ nextVersion: DBVersions, database: Database) throws {
        let queries = """
        CREATE TABLE 'Example2' (
        'id' TEXT NOT NULL
        );
        """
        try database.execute(sql: queries)
        try database.execute(sql: "PRAGMA user_version=\(nextVersion.rawValue)")
    }
    
    func didFinishStorageIncrementalMigrationSequence(startVersion: DBVersions, endVersion: DBVersions) {
    }
}
