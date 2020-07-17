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
public class OktaLoggerFileLogger : OktaLoggerDestinationBase {
    var fileLogger:DDFileLogger = DDFileLogger();
    var isLoggingActive = true;
    var logDirectory = "logs";
    
    /**
     Initilalize logger with log files in `logDirectory`
     */
    @objc
    convenience public init(logDirectory: String, identifier: String, level:OktaLoggerLogLevel, defaultProperties:[AnyHashable: Any]?) {
        self.init(identifier:identifier, level:level, defaultProperties:defaultProperties);
    }
    
    @objc
    override public init(identifier: String, level: OktaLoggerLogLevel, defaultProperties: [AnyHashable : Any]?) {
        super.init(identifier: identifier, level: level, defaultProperties: defaultProperties)
        self.setupLogger()
    }
    
    @objc
    override public func log(level: OktaLoggerLogLevel, eventName: String, message: String?, properties: [AnyHashable : Any]?, file: String, line: NSNumber, funcName: String) {
        
        let logMessage = self.stringValue(level: level,
                                          eventName: eventName,
                                          message: message,
                                          file: file, line: line, funcName: funcName)
        // translate log level into relevant console type level
        self.log(level: level, message:logMessage)
    }
    
    /**
     Log file path
     */
    @objc
    public func logDirectoryAbsolutePath() -> String?  {
        let path: String? = self.fileLogger.currentLogFileInfo?.filePath
        return path
    }
    
    @objc
    public func getLogs() -> [NSData] {
        var logFileDataArray:[NSData] = [];
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
        return logFileDataArray
    }
    
    @objc
    override open func logsCanBePurged() -> Bool {
        return true;
    }
    
    @objc
    override open func purgeLogs() {
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
    /**
     Remove all Loggers during de allocate
     */
    deinit {
        DDLog.remove(self.fileLogger)
    }
    
    /**
     Configure Logger Parameters
     */
    func setupLogger() {
        self.fileLogger.logFileManager.maximumNumberOfLogFiles = 1
        DDLog.add(self.fileLogger)
        self.isLoggingActive = true
        fileLogger.doNotReuseLogFiles=true
    }
    
    /**
     Create a structured string out of the logging parameters and properties
     */
    func stringValue(level: OktaLoggerLogLevel, eventName: String, message: String?, file: String, line: NSNumber, funcName: String) -> String {
        let filename = file.split(separator: "/").last
        let logMessageIcon = OktaLoggerLogLevel.logMessageIcon(level: level)
        return "{\(logMessageIcon) \"\(eventName)\": {\"message\": \"\(message ?? "")\", \"location\": \"\(filename ?? ""):\(funcName):\(line)\"}}"
    }
    
    /**
     Translate OktaLoggerLogLevel into a console-friendly OSLogType value
     */
    func log(level: OktaLoggerLogLevel, message:String) {
        switch level {
        case .debug:
            return DDLogDebug(message);
        case .info, .uiEvent:
            return DDLogInfo(message)
        case .error:
            return DDLogError(message)
        case .warning:
            return DDLogWarn(message)
        default:
            return DDLogInfo(message)
        }
    }
}
