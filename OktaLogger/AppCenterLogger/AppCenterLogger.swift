//
// Created by Brenner Ryan on 5/11/21.
// Copyright (c) 2021 Okta, Inc. All rights reserved.
//

import AppCenterAnalytics

/**
 Concrete logging class for App Center events.
 */
class AppCenterLogger: OktaLoggerDestinationBase {
    override open func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
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
    }
}
