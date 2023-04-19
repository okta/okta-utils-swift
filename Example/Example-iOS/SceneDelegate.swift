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

var scenarioID: ScenarioID = ""

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

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

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        FirebaseApp.configure()
        OktaAnalytics.addProvider(appCenterAnalyticsProvider)
        OktaAnalytics.trackEvent("applicationDidFinishLaunchingWithOptions", withProperties: nil)
        scenarioID = OktaAnalytics.startScenario("Application") { $0?.send(Property(key: "AppDelegate.application.didFinishLaunchingWithOptions", value: "1")) }
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        if scenarioID.isEmpty {
            scenarioID = OktaAnalytics.startScenario("Application") { $0?.send(Property(key: "SceneDelegate.sceneWillEnterForeground", value: "1")) }
        }
        OktaAnalytics.updateScenario(scenarioID) { $0?.send(Property(key: "SceneDelegate.sceneWillEnterForeground", value: "5")) }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        OktaAnalytics.updateScenario(scenarioID) { $0?.send(Property(key: "SceneDelegate.sceneDidBecomeActive", value: "5")) }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        OktaAnalytics.updateScenario(scenarioID) { $0?.send(Property(key: "SceneDelegate.sceneWillResignActive", value: "5")) }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        OktaAnalytics.updateScenario(scenarioID) { $0?.send(Property(key: "SceneDelegate.sceneDidEnterBackground", value: "5")) }
        OktaAnalytics.endScenario(scenarioID, eventDisplayName: "Finished")
        scenarioID = ""
    }
}
