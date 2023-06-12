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

import Foundation
import Combine
import OktaLogger
import AppCenterAnalytics

public class AppCenterAnalyticsProvider: NSObject, AnalyticsProviderProtocol {

    // MARK: - Properties

    public var defaultProperties: [String: String]?
    public var name: String
    public var logger: OktaLoggerProtocol?

    private var appCenter: AppCenterAnalytics.Analytics.Type = AppCenterAnalytics.Analytics.self
    private var isServicesStarted = false

    // MARK: - Initializer
       /**
        Initializes an instance of `AppCenterAnalyticsProvider`.

        - Parameters:
           - name: The name of the provider.
           - logger: An optional logger to use for logging events.
           - appCenter: An optional instance of `AppCenterAnalytics.Analytics.Type`.
        */
    public init(name: String, logger: OktaLoggerProtocol? = OktaLogger()) {
        self.name = name
        self.logger = logger
    }

    // MARK: - Public methods

    /**
     Tracks an event with the specified name and properties.

     - Parameters:
        - eventName: The name of the event to track.
        - withProperties: An optional dictionary of properties to include with the event.
     */
    public func trackEvent(_ eventName: String, withProperties: [String: String]?) {
        if !isServicesStarted {
            assert(false, "Services should start before trackEvent(_ eventName: withProperties:)")
        }
        var properties = withProperties ?? [:]
        Dictionary.mergeRecursive(left: &properties, right: defaultProperties)
        appCenter.trackEvent(eventName, withProperties: properties)
        logger?.log(level: .debug, eventName: eventName, message: nil, properties: properties, file: #file, line: #line, funcName: #function)
    }

    /**
     start the services for the`AppCenter` provider
     - Parameters:
     - appSecret: app secret for `AppCenter`
     - services: services to be registered with `AppCenter`
     */
    public func start(withAppSecret appSecret: String, services: [AnyClass]) {
        AppCenter.start(withAppSecret: appSecret, services: services)
        isServicesStarted = true
    }
}
