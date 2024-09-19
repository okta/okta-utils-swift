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
import Combine
import OktaLogger
import FirebaseAnalytics
import FirebaseCore

public class FirebaseAnalyticsProvider: NSObject, AnalyticsProviderProtocol {

    // MARK: - Properties

    public let defaultProperties: [String: String]?
    public let name: String
    public let logger: OktaLoggerProtocol?

    private var firebase: Analytics.Type = Analytics.self
    // MARK: - Initializer
       /**
        Initializes an instance of `FirebaseAnalyticsProvider`.
        */
    public required init(name: String, defaultProperties: Properties, logger: OktaLoggerProtocol? = OktaLogger()) {
        self.name = name
        self.defaultProperties = defaultProperties
        self.logger = logger
        if FirebaseApp.allApps == nil {
            FirebaseApp.configure()
        }
    }

    // MARK: - Public methods

    /**
     Tracks an event with the specified name and properties.

     - Parameters:
        - eventName: The name of the event to track.
        - withProperties: An optional dictionary of properties to include with the event.
     */
    public func trackEvent(_ eventName: String, withProperties: [String: String]?) {
        var properties = withProperties ?? [:]
        Dictionary.mergeRecursive(left: &properties, right: defaultProperties)
        firebase.logEvent(eventName, parameters: properties)
        logger?.log(level: .debug, eventName: eventName, message: nil, properties: properties, file: #file, line: #line, funcName: #function)
    }
}
