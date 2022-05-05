//
//  AppDelegate.swift
//  OktaLoggerExample-SPM
//
//  Created by Moises Olmedo Pina on 5/5/22.
//

import UIKit
import LoggerCore
@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let logger = OktaLogger()
        logger.addDestination(OktaLoggerConsoleLogger(identifier: "com.okta.loggerExampleSPM", level: .info, defaultProperties: nil))
        logger.info(eventName: "appLifecycle", message: "applicationDidFinishLaunchingWithOptions")
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

