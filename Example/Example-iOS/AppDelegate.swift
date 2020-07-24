//
//  AppDelegate.swift
//  OktaLoggerDemoApp
//
//  Created by Lihao Li on 6/5/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import UIKit
import OktaLogger

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let console = OktaLoggerConsoleLogger(identifier: "com.okta.OktaLoggerDemoApp.logger", level: .all, defaultProperties: nil)
        OktaLogger.main = OktaLogger(destinations: [console])
        return true
    }

}
