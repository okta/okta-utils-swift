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
import OktaSQLiteStorage
import GRDB
//import OktaAnalytics
//import AppCenterAnalytics

//var scenarioID: ScenarioID = ""

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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    /*let appCenterAnalyticsProvider: AnalyticsProviderProtocol = {
        let logger = OktaLogger()
        logger.addDestination(
            OktaLoggerConsoleLogger(
                identifier: "com.okta.loggerDemo.console",
                level: OktaLoggerLogLevel.debug,
                defaultProperties: nil
            )
        )
        let appCenterAnalyticsProvider = AppCenterAnalyticsProvider(name: "AppCenter", logger: logger)
        appCenterAnalyticsProvider.start(withAppSecret: "App Secret", services: [AppCenterAnalytics.Analytics.self])
        return appCenterAnalyticsProvider
    }()*/

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        FirebaseApp.configure()
        //OktaAnalytics.initializeStorageWith(securityAppGroupIdentifier: Bundle.main.object(forInfoDictionaryKey: "AppGroupId") as? String ?? "")
        //OktaAnalytics.addProvider(appCenterAnalyticsProvider)
        //OktaAnalytics.trackEvent("applicationDidFinishLaunchingWithOptions", withProperties: nil)
        //OktaAnalytics.startScenario(ScenarioEvent(name: "Application", properties: [Property(key: "AppDelegate.application.didFinishLaunchingWithOptions", value: "1")])) {
           // scenarioID = $0 ?? ""
        //}
        /*
        var dbURL: URL!
        if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURLs = try! FileManager.default.contentsOfDirectory(at: cacheURL,
                                                                       includingPropertiesForKeys: nil,
                                                                       options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                try? FileManager.default.removeItem(at: fileURL)
            }
            dbURL = cacheURL.appendingPathComponent("sqlite.db")
            try? FileManager.default.removeItem(at: dbURL)
        }
        
        let connectionBuilder = SQLiteConnectionBuilder()
        let dbPool = try! connectionBuilder.databasePool(at: dbURL, walModeEnabled: true, configuration: nil)
        
        try! dbPool.write { db in
            try! db.create(table: "player") { t in
                t.primaryKey("id", .text)
                t.column("name", .text).notNull()
                t.column("score", .integer).notNull()
            }
        }*/
        
        
        Task {
            var dbURL: URL!
            if let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheURL,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: .skipsHiddenFiles)
                for fileURL in fileURLs {
                    try? FileManager.default.removeItem(at: fileURL)
                }
                dbURL = cacheURL.appendingPathComponent("sqlite.db")
                try? FileManager.default.removeItem(at: dbURL)
            }
            
            let schemaQueries = """
            CREATE TABLE 'Example' (
            'id' TEXT NOT NULL
            );
            """

            let rawSQLSchema = SQLiteSchemaType.rawSQLSchema(sql: schemaQueries)
            let schema = SQLiteSchema(schemaType: rawSQLSchema, version: SchemaVersions.v1)
            let storage = try await SQLiteStorageBuilder()
                //.setWALMode(enabled: true)
                .build(schema: schema, storagePath: dbURL)
            
            try await storage.sqlitePool.write { db in
                try db.create(table: "player") { t in
                    t.primaryKey("id", .text)
                    t.column("name", .text).notNull()
                    t.column("score", .integer).notNull()
                }
            }
            try await storage.initialize(storageMigrator: SQLiteMigratorMock())

            try await storage.sqlitePool.write { db in
                try db.execute(literal: "INSERT INTO Example (id) VALUES (1)")
            }

            try await storage.sqlitePool.read { db in
                let db_version = try Int.fetchOne(db, sql: "PRAGMA user_version")
                let userData = try Int.fetchOne(db, sql: "SELECT id FROM Example WHERE id=1")
            }
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        /*if scenarioID.isEmpty {
            //OktaAnalytics.startScenario(ScenarioEvent(name: "Application", properties: [Property(key: "AppDelegate.application.sceneWillEnterForeground", value: "1")])) {
                //scenarioID = $0 ?? ""
            //}
        } else {
            //OktaAnalytics.updateScenario(scenarioID, [Property(key: "SceneDelegate.sceneWillEnterForeground", value: "2")])
        }*/
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        /*if scenarioID.isEmpty {
            /*OktaAnalytics.startScenario(ScenarioEvent(name: "Application", properties: [Property(key: "AppDelegate.application.sceneWillEnterForeground", value: "1")])) {
                scenarioID = $0 ?? ""
            }*/
        } else {
            //OktaAnalytics.updateScenario(scenarioID, [Property(key: "SceneDelegate.sceneDidBecomeActive", value: "4")])
        }*/
    }

    func sceneWillResignActive(_ scene: UIScene) {
        //OktaAnalytics.updateScenario(scenarioID, [Property(key: "SceneDelegate.sceneWillResignActive", value: "5")])
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        /*OktaAnalytics.updateScenario(scenarioID, [Property(key: "SceneDelegate.sceneDidEnterBackground", value: "5")])
        OktaAnalytics.getOngoingScenarioIds("Application") {
            print($0)
        }
        OktaAnalytics.endScenario(scenarioID, eventDisplayName: "Entered background")
        scenarioID = ""*/
    }
}
