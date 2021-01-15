//
//  AppDelegate.swift
//  OktaLoggerDemoApp
//
//  Created by Lihao Li on 6/5/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import UIKit
import OktaLogger
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}

class LoggingManager {

    static let shared = LoggingManager()
    private (set) var defaultLogger: OktaLogger

    init() {
        let consoleDestination = OktaLoggerConsoleLogger(
            identifier: "com.okta.OktaLoggerDemoApp.logger",
            level: .info,
            defaultProperties: nil
        )
        let firebaseCrashlyticsDestination = LoggingManager.buildFirebaseCrashlyticsLogger()
        defaultLogger = OktaLogger(destinations: [consoleDestination, firebaseCrashlyticsDestination])
    }

    static private func buildFirebaseCrashlyticsLogger() -> OktaLoggerFirebaseCrashlyticsLogger {
        FirebaseApp.configure()
        let crashlytics = Crashlytics.crashlytics()
        crashlytics.setUserID("test123")

        return OktaLoggerFirebaseCrashlyticsLogger(
            crashlytics: crashlytics,
            identifier: "com.okta.OktaLoggerDemoApp.crashlyticsLogger",
            level: .all
        )
    }
}
