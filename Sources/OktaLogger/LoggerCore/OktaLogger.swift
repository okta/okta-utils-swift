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

/**
 Public interface for main OktaLogger instances
 */
@objc
public protocol OktaLoggerProtocol {
    /**
     - Parameters:
        - destinations: List of OktaLoggerDestinations
     */
    init(destinations: [OktaLoggerDestinationProtocol])

    /**
    Logging super-method for all parameters

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
     Update the log level for one or all destinations

     - Parameters:
         - level: OktaLoggerLogLevel to set
         - identifiers: destination identifiers to be updated
     */
    func setLogLevel(level: OktaLoggerLogLevel, identifiers: [String])

    /**
     Convenience method for log(level: .debug, ...)
     */
    func debug(eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String)

    /**
     Convenience method for log(level: .info, ...)
     */
    func info(eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String)

    /**
     Convenience method for log(level: .warning, ...)
     */
    func warning(eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String)

    /**
     Convenience method for log(level: .uievent, ...)
     */
    func uiEvent(eventName: String,
                       message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String)
    /**
     Convenience method for log(level: .error, ...)
     */
    func error(eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String)

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
        - identifiers: defaultProperties will be added to destinations which identifiers are contained in identifiers. If it's nil, defaultProperties will be added to all destinations
     */
    func addDefaultProperties(_ defaultProperties: [AnyHashable: Any], identifiers: [String]?)

    /**
     Remove properties

     - Parameters:
        - key: defaultProperties to be removed by key
        - identifiers: key-value defaultProperties will be removed from destinations which identifiers are contained in identifiers. If it's nil, key-value defaultProperties will be removed from all destinations
     */
    func removeDefaultProperties(for key: AnyHashable, identifiers: [String]?)

    /**
     Add new logging destination.

     - Parameters:
        - destination: Logging destination to add. It won't be added if logger already has destination with the same identifier.
     */
    func addDestination(_ destination: OktaLoggerDestinationProtocol)

    /**
     Remove logging destination by identifier.

     - Parameters:
        - identifier: Identifier of destination which should be removed.
     */
    func removeDestination(withIdentifier identifier: String)
}

public extension OktaLoggerProtocol {

    func debug(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .debug, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    func info(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .info, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    func warning(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .warning, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    func uiEvent(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .uiEvent, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    func error(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .error, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }
}

/**
 Main Logger Proxy
 */
@objc
open class OktaLogger: NSObject, OktaLoggerProtocol {

    private var loggingDestinations: [String: OktaLoggerDestinationProtocol]
    private var destinationsLock = ReadWriteLock()

    // MARK: Public

    public required init(destinations: [OktaLoggerDestinationProtocol]) {
        var destinationDict = [String: OktaLoggerDestinationProtocol]()
        destinations.forEach { destination in
            destinationDict[destination.identifier] = destination
        }
        self.loggingDestinations = destinationDict
    }

    override public convenience init() {
        self.init(destinations: [])
    }

    public var destinations: [String: OktaLoggerDestinationProtocol] {
        destinationsLock.readLock()
        defer { destinationsLock.unlock() }
        return loggingDestinations
    }

    public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String = #file, line: NSNumber = #line, funcName: String = #function) {

        forEachDestination(withLogLevel: level) { logger in
            logger.log(
                level: level,
                eventName: eventName,
                message: message,
                properties: properties ?? logger.defaultProperties,
                file: file, line: line, funcName: funcName
            )
        }
    }

    public func setLogLevel(level: OktaLoggerLogLevel, identifiers: [String]) {
        for identifier in identifiers {
            if let destination = self.destinations[identifier] {
                destination.level = level
            }
        }
    }

    public func debug(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .debug, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    public func info(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .info, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    public func warning(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .warning, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    public func uiEvent(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .uiEvent, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    public func error(eventName: String, message: String?, properties: [AnyHashable: Any]? = nil, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        log(level: .error, eventName: eventName, message: message, properties: properties, file: file, line: line, funcName: funcName)
    }

    public func log(error: NSError, file: String = #file, line: NSNumber = #line, funcName: String = #function) {
        forEachDestination(withLogLevel: .error) { logger in
            logger.log(error: error, file: file, line: line, funcName: funcName)
        }
    }

    public func addDefaultProperties(_ defaultProperties: [AnyHashable: Any], identifiers: [String]?) {
        destinations.forEach { (identifier, destination) in
            if (identifiers == nil) || (identifiers?.contains(identifier) ?? true) {
                destination.addDefaultProperties(defaultProperties)
            }
        }
    }

    public func removeDefaultProperties(for key: AnyHashable, identifiers: [String]?) {
        destinations.forEach { (identifier, destination) in
            if (identifiers == nil) || (identifiers?.contains(identifier) ?? true) {
                destination.removeDefaultProperties(for: key)
            }
        }
    }

    public func addDestination(_ destination: OktaLoggerDestinationProtocol) {
        guard !destinations.keys.contains(destination.identifier) else {
            return
        }
        destinationsLock.writeLock()
        defer { destinationsLock.unlock() }
        loggingDestinations[destination.identifier] = destination
    }

    public func removeDestination(withIdentifier identifier: String) {
        destinationsLock.writeLock()
        defer { destinationsLock.unlock() }
        loggingDestinations.removeValue(forKey: identifier)
    }
}

private extension OktaLogger {

    /**
     Iterates through all of the destinations and calls closure
     if logger can process specified log level.
     */
    func forEachDestination(withLogLevel level: OktaLoggerLogLevel, closure: (OktaLoggerDestinationProtocol) -> ()) {
        for logger in self.destinations.values {
            // check the logging level of this destination
            let levelCheck = (logger.level.rawValue & level.rawValue) == level.rawValue
            if !levelCheck { continue }
            closure(logger)
        }
    }
}

