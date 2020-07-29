//
//  OktaLoggerFileLogger.swift
//  OktaLogger
//
//  Created by Kaushik Krishnakumar on 7/9/20.
//  Copyright © 2020 Okta, Inc. All rights reserved.
//

import Foundation
import CocoaLumberjack

@objc
public class OktaLoggerFileLogger: OktaLoggerDestinationBase {

    var delegate:LoggerDelegate

    // MARK: Intializing logger
    @objc
    public init(logConfig: OktaLoggerFileLoggerConfig, identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        delegate = LumberjackLoggerDelegate(logConfig)
        super.init(identifier: identifier, level: level, defaultProperties: defaultProperties)
        let logConfig = OktaLoggerFileLoggerConfig(rollingFrequency: logConfig.rollingFrequency)
    }

    @objc
    override public convenience init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        let logConfig = OktaLoggerFileLoggerConfig(rollingFrequency: 60 * 60 * 48)
        self.init(logConfig: logConfig, identifier: identifier, level: level, defaultProperties: defaultProperties)
    }

    // MARK: Logging
    @objc
    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {
        let log = self.stringValue(level: level, eventName: eventName, message:message, file: file, line:line, funcName:funcName)
        delegate.log(level, log)
    }

    /**
     Log file path
     */
    @objc
    public func logDirectoryAbsolutePath() -> String? {
        return delegate.dirPath()
    }

    // MARK: Retrieve Logs
    /**
            Non thread safe implementation to retrieve logs.
     */
    @objc
    public func getLogs() -> [Data] {
        return delegate.getLogs()
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

protocol LoggerDelegate {

    //MARK: Logging
    func log(_ level:OktaLoggerLogLevel, _ message:String)
    func dirPath() -> String?

    //MARK: retrieval
    func getLogs() -> [Data]
    func getLogs(completion: @escaping ([Data]) -> Void)

    // MARK: purge
    func logsCanBePurged() -> Bool
    func purgeLogs()
}

class LumberjackLoggerDelegate: LoggerDelegate {
    var fileLogger: DDFileLogger = DDFileLogger()
    var isLoggingActive = true

    /**
     Configure Logger Parameters
     */
    init(_ logConfig: OktaLoggerFileLoggerConfig) {
        self.fileLogger.logFileManager.maximumNumberOfLogFiles = 1
        self.fileLogger.rollingFrequency = logConfig.rollingFrequency
        DDLog.add(self.fileLogger)
        self.isLoggingActive = true
        fileLogger.doNotReuseLogFiles = true
    }

    /**
     Log file path
     */
    @objc
    func dirPath() -> String? {
        let path: String? = self.fileLogger.currentLogFileInfo?.filePath
        return path
    }

    // MARK: Retrieve Logs
    /**
            Non thread safe implementation to retrieve logs.
     */
    @objc
    func getLogs() -> [Data] {
        self.fileLogger.flush()
        // pause logging to avoid corruption
        self.isLoggingActive = false
        var logFileDataArray: [Data] = []
        //        The first item in the array will be the most recently created log file.
        let logFileInfos = self.fileLogger.logFileManager.sortedLogFileInfos
        for logFileInfo in logFileInfos {
            if logFileInfo.isArchived {
                continue
            }
            let logFilePath = logFileInfo.filePath
            let fileURL = NSURL(fileURLWithPath: logFilePath)
            if let logFileData = try? NSData(contentsOf: fileURL as URL, options: NSData.ReadingOptions.mappedIfSafe) {
                // Insert at front to reverse the order, so that oldest logs appear first.
                logFileDataArray.insert(logFileData as Data, at: 0)
            }
        }
        // Resume logging
        self.isLoggingActive = true
        return logFileDataArray
    }

    /**
        Retrieves log data asynchronously. Completion block is always executed in main queue
    */
    @objc
    func getLogs(completion: @escaping ([Data]) -> Void) {
        // fetch logs
        DispatchQueue.global(qos: .userInitiated).async {
            let logData = self.getLogs()
            DispatchQueue.main.async {
                completion(logData)
            }
        }
    }

    // MARK: Purge Logs
    @objc
    func logsCanBePurged() -> Bool {
        return true
    }

    @objc
    func purgeLogs() {
        if !logsCanBePurged() {
            return
        }
        self.fileLogger.rollLogFile(withCompletion: {
            do {
                for logFileInfo in self.fileLogger.logFileManager.sortedLogFileInfos {
                    if !logFileInfo.isArchived {
                        continue
                    }
                    let logPath = logFileInfo.filePath
                    try FileManager.default.removeItem(atPath: logPath)
                    guard let logFile = self.fileLogger.currentLogFileInfo else {
                        print("Unable to reinit file logger")
                        return
                    }
                    print("Intialized Log at \(logFile.filePath)")
                }
            } catch { error
                print("Error purging log: \(error.localizedDescription)")
            }
        })
    }

    // MARK: Internal methods
    /**
     Remove all Loggers during deallocate
     */
    deinit {
        DDLog.remove(self.fileLogger)
    }

    /**
     Translate log message  into DDLog message
     */
    func log(_ level: OktaLoggerLogLevel,_ message: String) {
        if  !self.isLoggingActive {
            return
        }

        switch level {
        case .debug:
            return DDLogDebug(message)
        case .info, .uiEvent:
            return DDLogInfo(message)
        case .error:
            return DDLogError(message)
        case .warning:
            return DDLogWarn(message)
        default:
            // default info
            return  DDLogInfo(message)
        }
    }
}