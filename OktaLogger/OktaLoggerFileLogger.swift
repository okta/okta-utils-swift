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
    var fileLogger: DDFileLogger = DDFileLogger()
    var isLoggingActive = true

    // MARK: Intializing logger
    @objc
    public init(logConfig: OktaLoggerFileLoggerConfig, identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        super.init(identifier: identifier, level: level, defaultProperties: defaultProperties)
        let logConfig = OktaLoggerFileLoggerConfig(rollingFrequency: logConfig.rollingFrequency)
        self.setupLogger(logConfig)
    }

    @objc
    public convenience override init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable: Any]?) {
        let logConfig = OktaLoggerFileLoggerConfig(rollingFrequency: 60 * 60 * 48)
        self.init(logConfig: logConfig, identifier: identifier, level: level, defaultProperties: defaultProperties)
    }

    // MARK: Logging
    @objc
    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable: Any]?, file: String, line: NSNumber, funcName: String) {

        let logMessage = self.stringValue(level: level,
                                          eventName: eventName,
                                          message: message,
                                          file: file, line: line, funcName: funcName)
        // translate log level into relevant console type level
        self.log(level: level, message: logMessage)
    }

    /**
     Log file path
     */
    @objc
    public func logDirectoryAbsolutePath() -> String? {
        let path: String? = self.fileLogger.currentLogFileInfo?.filePath
        return path
    }

    // MARK: Retrieve Logs
    /**
            Non thread safe implementation to retrieve logs.
     */
    @objc
    public func getLogs() -> [NSData] {
        self.fileLogger.flush()
        // pause logging to avoid corruption
        self.isLoggingActive = false
        var logFileDataArray: [NSData] = []
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
                logFileDataArray.insert(logFileData, at: 0)
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
    public func getLogsAsync(completion: @escaping ([NSData]) -> Void) {
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
    override open func logsCanBePurged() -> Bool {
        return true
    }

    @objc
    override open func purgeLogs() {
        if !logsCanBePurged() {
            return
        }
        self.isLoggingActive = false
        self.fileLogger.rollLogFile(withCompletion: {
            do {
                self.isLoggingActive = true
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
     Configure Logger Parameters
     */
    func setupLogger(_ logConfig: OktaLoggerFileLoggerConfig) {
        self.fileLogger.logFileManager.maximumNumberOfLogFiles = 1
        self.fileLogger.rollingFrequency = logConfig.rollingFrequency
        DDLog.add(self.fileLogger)
        self.isLoggingActive = true
        fileLogger.doNotReuseLogFiles=true
    }

    /**
     Translate log message  into DDLog message
     */
    func log(level: OktaLoggerLogLevel, message: String) {
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
