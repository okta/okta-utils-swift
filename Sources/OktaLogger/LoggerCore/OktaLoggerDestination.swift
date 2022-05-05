/*
 * Copyright (c) 2021-Present, Okta, Inc. and/or its affiliates. All rights reserved.
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

/**
 Logger destination protocol interface to be implemented by concrete loggers
 */
@objc
public protocol OktaLoggerDestinationProtocol {

    /**
     Unique for this logging destination, e.g. "com.okta.console" or "com.google.firebase.analytics"
     Only one logger per identifier is permitted
     */
    var identifier: String { get }

    /**
     Logging level for this destination
     */
    var level: OktaLoggerLogLevel { get set }

    /**
     Default event properties.
     Note: this might be limited for some logging destinations, i.e Firebase destination relies on `Keys` property which has a limit of 64 key-value pairs.
     */
    var defaultProperties: [AnyHashable: Any] { get }

    /**
     Logging super-method, to be implemented by all concrete logging destinations

     - Parameters:
     - level: OktaLoggerLogLevel for this event
     - eventName: name for this event
     - message: message for this event (optional)
     - properties: key-value properties for this event (optional)
     */
    func log(level: OktaLoggerLogLevel,
             eventName: String,
             message: String?,
             properties: [AnyHashable: Any]?,
             file: String,
             line: NSNumber,
             funcName: String)

    /**
     Log NSError object.

     - Parameters
        - error: NSError object to log.
     */
    func log(error: NSError, file: String, line: NSNumber, funcName: String)

    /**
     Add default properties to one or more destinations

     - Parameters:
        - defaultProperties: defaultProperties to be added to destinations
     */
    func addDefaultProperties(_ defaultProperties: [AnyHashable: Any])

    /**
     Remove properties

     - Parameters:
        - key: defaultProperties to be removed by key
     */
    func removeDefaultProperties(for key: AnyHashable)
}

/**
 Abstract logger destination class, makes automates atomic level setting and simple init
 */
@objc
open class OktaLoggerDestinationBase: NSObject, OktaLoggerDestinationProtocol {
    public let identifier: String

    @objc
    public init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        self.identifier = identifier
        self._level = level
        self._defaultProperties = defaultProperties ?? [AnyHashable: Any]()
        self.defaultPropertiesDescription = Self.description(of: self._defaultProperties)
    }

    public var defaultProperties: [AnyHashable: Any] {
        get {
            self.lock.readLock()
            defer { self.lock.unlock() }
            return self._defaultProperties
        }
        set (value) {
            self.lock.writeLock()
            defer { self.lock.unlock() }
            self._defaultProperties = value
            self.defaultPropertiesDescription = Self.description(of: self._defaultProperties)
        }
    }

    /**
     Atomic get and set using readwrite lock
     */
    public var level: OktaLoggerLogLevel {
        get {
            self.lock.readLock()
            defer { self.lock.unlock() }
            return self._level
        }
        set (value) {
            self.lock.writeLock()
            defer { self.lock.unlock() }
            self._level = value
        }
    }

    /**
     Log function must be overridden by subclasses
     */
    open func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {}

    open func logsCanBePurged() -> Bool {
        return false
    }

    open func purgeLogs() {}

    /**
     This method can be overridden by subclass.
     Default implementation will call log(level:) function with `error` level
     and pass `error.domain` and `error.code` as `eventName` parameter,
     `error.localizedDescription` as `message` and `error.userInfo` as `properties`.
     */
    open func log(error: NSError, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        let eventName = "\(error.domain), \(error.code)"
        let message = error.localizedDescription
        let properties = error.userInfo
        log(level: .error, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    /**
     Create a structured string out of the logging parameters and properties
     */
    open func stringValue(level: OktaLoggerLogLevel, eventName: String, message: String?, file: String, line: NSNumber, funcName: String) -> String {
        let filename = file.split(separator: "/").last
        let logMessageIcon = OktaLoggerLogLevel.logMessageIcon(level: level)
        return "{\(logMessageIcon) \"\(eventName)\": {\"message\": \"\(message ?? "")\", \"defaultProperties\": \"\(defaultPropertiesDescription)\", \"location\": \"\(filename ?? ""):\(funcName):\(line)\"}}"
    }

    open func addDefaultProperties(_ defaultProperties: [AnyHashable: Any]) {
        var updatedProperties = self.defaultProperties
        updatedProperties.merge(defaultProperties, uniquingKeysWith: { (_, last) in last })
        self.defaultProperties = updatedProperties
    }

    open func removeDefaultProperties(for key: AnyHashable) {
        var updatedProperties = defaultProperties
        updatedProperties.removeValue(forKey: key)
        defaultProperties = updatedProperties
    }


    // MARK: Private

    private var lock = ReadWriteLock()
    private var _level: OktaLoggerLogLevel
    private var _defaultProperties: [AnyHashable: Any]
    private var defaultPropertiesDescription: String

    private static func description(of dictionary: [AnyHashable: Any]) -> String {
        return dictionary
            .map { (key: String(describing: $0.key), value: $0.value) }
            .sorted(by: { $0.key < $1.key })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "; ")
    }
}
