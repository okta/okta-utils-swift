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
 Analytics class for holding and tracking for different tracking provider
 */
@objc
public final class OktaAnalytics: NSObject {

    private static var providers = [String: AnalyticsProviderProtocol]()
    private static var lock = ReadWriteLock()

    /**
     Adds provider to collection

     - Parameters:
     - provider: `AnalyticsProviderProtocol` provided by client
     */
    public static func addProvider(_ provider: AnalyticsProviderProtocol) {
        lock.writeLock()
        defer { lock.unlock() }
        providers[provider.name] = provider
    }

    /**
     Adds providers to collection

     - Parameters:
     - providers: `AnalyticsProviderProtocol`s provided by client
     */
    public static func addProviders(_ providers: [AnalyticsProviderProtocol]) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.forEach {
            Self.providers[$0.name] = $0
        }
    }

    /**
     removes providers by name

     - Parameters:
     - provider: name of the provider
     */
    public static func removeProvider(_ provider: String) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.removeValue(forKey: provider)
    }

    /**
     Remove providers from collection

     - Parameters:
     - providers: `Provider`s provided by client, if exists
     */
    public static func removeProviders(_ providers: [String]) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.forEach { Self.providers.removeValue(forKey: $0) }
    }

    /**
     Remove provider from collection

     - Parameters:
     - provider: `AnalyticsProviderProtocol` provided by client, if exists
     */
    static func removeProvider(_ provider: AnalyticsProviderProtocol) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.removeValue(forKey: provider.name)
    }

    /**
     Remove providers from collection

     - Parameters:
     - providers: `AnalyticsProviderProtocol`s provided by client, if exists
     */
    static func removeProviders(_ providers: [AnalyticsProviderProtocol]) {
        lock.writeLock()
        defer { lock.unlock() }
        providers.forEach { Self.providers.removeValue(forKey: $0.name) }
    }

    /**
     Track event to all providers provided by client

     - Parameters:
     - eventName: `event name` provided by client
     - withProperties: `properties/metadata` associated with event
     */
    public static func trackEvent(_ eventName: String, withProperties: [String: String]?) {
        lock.readLock()
        defer { lock.unlock() }
        providers.forEach { $1.trackEvent(eventName, withProperties: withProperties) }
    }

    /**
     removes all providers from memory
     */
    public static func purge() {
        lock.writeLock()
        defer { lock.unlock() }
        providers.removeAll()
    }
}

public extension Dictionary {
    // Merge the contents of one dictionary into another, favoring the content of right
    static func mergeRecursive(left: inout Self, right: Self?) {
        left.merge(right ?? [:]) { current, _ in current }
    }
}

private extension OktaAnalytics {
    class ReadWriteLock: NSObject {

        func writeLock() {
            pthread_rwlock_wrlock(&self.lock)
        }

        func readLock() {
            pthread_rwlock_rdlock(&self.lock)
        }

        func unlock() {
            pthread_rwlock_unlock(&self.lock)
        }

        deinit {
            pthread_rwlock_destroy(&self.lock)
        }

        override init() {
            self.lock = pthread_rwlock_t()
            pthread_rwlock_init(&self.lock, nil)
        }

        private var lock: pthread_rwlock_t
    }
}
