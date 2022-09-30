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
import OktaLogger

/**
 Protocol: Client needs to implement this protocol and provide the information about provider
 */
@objc
public protocol AnalyticsProviderProtocol: AnyObject {

    /// provider name, eg: Firebase, AppCenter etc.
    var name: String { get set }
    /// logger to post logs on it's destination
    var logger: OktaLoggerProtocol? { get set }
    /// default properties that post with all events
    var defaultProperties: [String: String]? { get set }
    /// Tracks event to the provider
    func trackEvent(_ eventName: String, withProperties: [String: String]?)
}

public extension AnalyticsProviderProtocol {
    var defaultProperties: [String: String]? { nil }
    var logger: OktaLoggerProtocol? { nil }
}


/// TODO: change to public when start working on phase II
private extension AnalyticsProviderProtocol {
    func trackOperation(_ operation: TrackedOperation) { }
}

private protocol TrackedOperation {
    func start()
    func pause()
    func stop()
}
