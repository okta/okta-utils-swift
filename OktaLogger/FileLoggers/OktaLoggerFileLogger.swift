//
//  OktaLoggerFileLogger.swift
//  OktaLogger
//
//  Created by Kaushik Krishnakumar on 7/9/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import Foundation

@objc
public class OktaLoggerFileLogger: OktaLoggerDestinationBase {

    var delegate: FileLoggerDelegate

    // MARK: Intializing logger
    @objc
    public init(logConfig: OktaLoggerFileLoggerConfig, identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        delegate = LumberjackLoggerDelegate(logConfig)
        super.init(identifier: identifier, level: level, defaultProperties: defaultProperties)
    }

    @objc
    override public convenience init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        let logConfig = OktaLoggerFileLoggerConfig(rollingFrequency: 60 * 60 * 48)
        self.init(logConfig: logConfig, identifier: identifier, level: level, defaultProperties: defaultProperties)
    }

    // MARK: Logging
    @objc
    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
        let log = self.stringValue(level: level, eventName: eventName, message: message, file: file, line: line, funcName: funcName)
        delegate.log(level, log)
    }

    /**
     Log file path
     */
    @objc
    public func logDirectoryAbsolutePath() -> String? {
        return delegate.directoryPath()
    }

    // MARK: Retrieve Logs
    /**
            Non thread safe implementation to retrieve logs.
     */
    @objc
    public func getLogs() -> [Data] {
        return delegate.getLogs()
    }

    // MARK: Retrieve log files' paths
    @objc
    public func getLogPaths() -> [URL] {
        return delegate.getLogPaths()
    }

    /**
        Retrieves log data asynchronously. Completion block is always executed in main queue
    */
    @objc
    public func getLogs(completion: @escaping ([Data]) -> Void) {
        // fetch logs
        delegate.getLogs(completion: completion)
    }

    // MARK: Purge Logs
    @objc
    override open func logsCanBePurged() -> Bool {
        return delegate.logsCanBePurged()
    }

    @objc
    override open func purgeLogs() {
        if !logsCanBePurged() {
            return
        }
        delegate.purgeLogs()
    }

    /**
     Translate log message  into DDLog message
     */
    func log(level: OktaLoggerLogLevel, message: String) {
       delegate.log(level, message)
    }
}
