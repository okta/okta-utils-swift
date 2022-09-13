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

#if canImport(AppCenterAnalytics)
import AppCenterAnalytics
#endif
import OktaLogger

/**
 Concrete logging class for App Center events.
 */
class AppCenterLogger: OktaLoggerDestinationBase {
    override open func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
        #if canImport(AppCenterAnalytics)
        switch level {
        case .error:
            guard let propertiesStrings = properties as? [String: String] else {
                Analytics.trackEvent(eventName)
                return
            }
            Analytics.trackEvent(eventName, withProperties: propertiesStrings, flags: .critical)
        default:
            guard let propertiesStrings = properties as? [String: String] else {
                Analytics.trackEvent(eventName)
                return
            }
            Analytics.trackEvent(eventName, withProperties: propertiesStrings)
        }
        #endif
    }
}
