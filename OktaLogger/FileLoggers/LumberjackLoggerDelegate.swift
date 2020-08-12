//
// Created by Kaushik Krishnakumar on 7/29/20.
// Copyright (c) 2020 Okta, Inc. All rights reserved.
//

import CocoaLumberjack

class LumberjackLoggerDelegate: FileLoggerDelegate {
    var fileLogger: DDFileLogger = DDFileLogger()
    var isLoggingActive = true

    /**
     Configure Logger Parameters
     */
    public init(_ logConfig: OktaLoggerFileLoggerConfig) {
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
    func directoryPath() -> String? {
        let path: String? = self.fileLogger.currentLogFileInfo?.filePath
        return path
    }

    // MARK: Retrieve Logs
    /**
     Non thread safe implementation to retrieve logs.
    */
    @objc
    func getLogs() -> [Data] {
        return getLogInfos().data
    }

    // MARK: Retrieve log file paths
    /**
     Non thread safe implementation to retrieve log file paths..
    */
    @objc
    func getLogPaths() -> [URL] {
        return getLogInfos().paths
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
            } catch {
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
    func log(_ level: OktaLoggerLogLevel, _ message: String) {
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

    // MARK: Private method to retrieve logs and file paths
    /**
     Non thread safe implementation to retrieve logs and file paths.
     */
    private func getLogInfos() -> (data: [Data], paths: [URL]) {
        self.fileLogger.flush()
        // pause logging to avoid corruption
        self.isLoggingActive = false
        var logFilePathArray = [URL]()
        var logFileDataArray = [Data]()
        // the first item in the array will be the most recently created log file.
        let logFileInfos = self.fileLogger.logFileManager.sortedLogFileInfos
        for logFileInfo in logFileInfos {
            if logFileInfo.isArchived {
                continue
            }
            let logFilePath = logFileInfo.filePath
            let fileURL = URL(fileURLWithPath: logFilePath)
            if let logFileData = try? Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe) {
                // Insert at front to reverse the order, so that oldest logs appear first.
                logFilePathArray.insert(fileURL, at: 0)
                logFileDataArray.insert(logFileData as Data, at: 0)
            }
        }
        // Resume logging
        self.isLoggingActive = true
        return (logFileDataArray, logFilePathArray)
    }
}
